package cache

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/jxlxx/civicrm/pkg/config"
	"github.com/jxlxx/civicrm/pkg/logger"
	"github.com/redis/go-redis/v9"
)

// Manager manages multiple cache layers
type Manager struct {
	config *config.CacheConfig
	memory *MemoryCache
	redis  *RedisCache
	local  *LocalCache
	logger *logger.Logger
}

// New creates a new cache manager
func New(config *config.CacheConfig) (*Manager, error) {
	manager := &Manager{
		config: config,
	}

	// Initialize memory cache
	manager.memory = NewMemoryCache(config.MaxMemory, config.MaxEntries)

	// Initialize Redis cache if configured
	if config.Driver == "redis" {
		redisCache, err := NewRedisCache(config)
		if err != nil {
			return nil, fmt.Errorf("failed to initialize Redis cache: %w", err)
		}
		manager.redis = redisCache
	}

	// Initialize local cache
	manager.local = NewLocalCache(config.MaxMemory/10, config.MaxEntries/10)

	return manager, nil
}

// Get retrieves a value from cache
func (m *Manager) Get(ctx context.Context, key string) (interface{}, error) {
	// Try local cache first (fastest)
	if val, found := m.local.Get(key); found {
		return val, nil
	}

	// Try memory cache
	if val, found := m.memory.Get(key); found {
		// Update local cache
		m.local.Set(key, val, m.config.TTL)
		return val, nil
	}

	// Try Redis cache if available
	if m.redis != nil {
		if val, err := m.redis.Get(ctx, key); err == nil {
			// Update memory and local caches
			m.memory.Set(key, val, m.config.TTL)
			m.local.Set(key, val, m.config.TTL)
			return val, nil
		}
	}

	return nil, fmt.Errorf("key not found: %s", key)
}

// Set stores a value in cache
func (m *Manager) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
	// Set in all cache layers
	m.local.Set(key, value, ttl)
	m.memory.Set(key, value, ttl)

	if m.redis != nil {
		return m.redis.Set(ctx, key, value, ttl)
	}

	return nil
}

// Delete removes a value from cache
func (m *Manager) Delete(ctx context.Context, key string) error {
	m.local.Delete(key)
	m.memory.Delete(key)

	if m.redis != nil {
		return m.redis.Delete(ctx, key)
	}

	return nil
}

// Clear clears all cache layers
func (m *Manager) Clear(ctx context.Context) error {
	m.local.Clear()
	m.memory.Clear()

	if m.redis != nil {
		return m.redis.Clear(ctx)
	}

	return nil
}

// Close closes cache connections
func (m *Manager) Close() error {
	if m.redis != nil {
		return m.redis.Close()
	}
	return nil
}

// SetLogger sets the logger for the cache manager
func (m *Manager) SetLogger(logger *logger.Logger) {
	m.logger = logger
}

// MemoryCache provides in-memory caching
type MemoryCache struct {
	data       map[string]cacheItem
	maxMemory  int64
	maxEntries int
	mutex      sync.RWMutex
}

type cacheItem struct {
	value      interface{}
	expiration time.Time
	size       int64
}

// NewMemoryCache creates a new memory cache
func NewMemoryCache(maxMemory int64, maxEntries int) *MemoryCache {
	return &MemoryCache{
		data:       make(map[string]cacheItem),
		maxMemory:  maxMemory,
		maxEntries: maxEntries,
	}
}

// Get retrieves a value from memory cache
func (c *MemoryCache) Get(key string) (interface{}, bool) {
	c.mutex.RLock()
	defer c.mutex.RUnlock()

	item, found := c.data[key]
	if !found {
		return nil, false
	}

	if time.Now().After(item.expiration) {
		delete(c.data, key)
		return nil, false
	}

	return item.value, true
}

// Set stores a value in memory cache
func (c *MemoryCache) Set(key string, value interface{}, ttl time.Duration) {
	c.mutex.Lock()
	defer c.mutex.Unlock()

	// Clean expired items first
	c.cleanup()

	// Check capacity constraints
	if len(c.data) >= c.maxEntries {
		c.evictOldest()
	}

	item := cacheItem{
		value:      value,
		expiration: time.Now().Add(ttl),
		size:       64, // Simplified size calculation
	}

	c.data[key] = item
}

// Delete removes a value from memory cache
func (c *MemoryCache) Delete(key string) {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	delete(c.data, key)
}

// Clear clears all memory cache
func (c *MemoryCache) Clear() {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	c.data = make(map[string]cacheItem)
}

// cleanup removes expired items
func (c *MemoryCache) cleanup() {
	now := time.Now()
	for key, item := range c.data {
		if now.After(item.expiration) {
			delete(c.data, key)
		}
	}
}

// evictOldest removes the oldest entry when at capacity
func (c *MemoryCache) evictOldest() {
	var oldestKey string
	var oldestTime time.Time

	for key, item := range c.data {
		if oldestKey == "" || item.expiration.Before(oldestTime) {
			oldestKey = key
			oldestTime = item.expiration
		}
	}

	if oldestKey != "" {
		delete(c.data, oldestKey)
	}
}

// LocalCache provides per-instance caching
type LocalCache struct {
	data       map[string]interface{}
	maxMemory  int64
	maxEntries int
	mutex      sync.RWMutex
}

// NewLocalCache creates a new local cache
func NewLocalCache(maxMemory int64, maxEntries int) *LocalCache {
	return &LocalCache{
		data:       make(map[string]interface{}),
		maxMemory:  maxMemory,
		maxEntries: maxEntries,
	}
}

// Get retrieves a value from local cache
func (c *LocalCache) Get(key string) (interface{}, bool) {
	c.mutex.RLock()
	defer c.mutex.RUnlock()
	val, found := c.data[key]
	return val, found
}

// Set stores a value in local cache
func (c *LocalCache) Set(key string, value interface{}, ttl time.Duration) {
	c.mutex.Lock()
	defer c.mutex.Unlock()

	if len(c.data) >= c.maxEntries {
		// Simple FIFO eviction
		for k := range c.data {
			delete(c.data, k)
			break
		}
	}

	c.data[key] = value
}

// Delete removes a value from local cache
func (c *LocalCache) Delete(key string) {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	delete(c.data, key)
}

// Clear clears all local cache
func (c *LocalCache) Clear() {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	c.data = make(map[string]interface{})
}

// RedisCache provides Redis-based caching
type RedisCache struct {
	client *redis.Client
}

// NewRedisCache creates a new Redis cache
func NewRedisCache(config *config.CacheConfig) (*RedisCache, error) {
	client := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%d", config.Host, config.Port),
		Password: config.Password,
		DB:       config.Database,
	})

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, err
	}

	return &RedisCache{client: client}, nil
}

// Get retrieves a value from Redis
func (c *RedisCache) Get(ctx context.Context, key string) (interface{}, error) {
	val, err := c.client.Get(ctx, key).Result()
	if err != nil {
		return nil, err
	}
	return val, nil
}

// Set stores a value in Redis
func (c *RedisCache) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
	return c.client.Set(ctx, key, value, ttl).Err()
}

// Delete removes a value from Redis
func (c *RedisCache) Delete(ctx context.Context, key string) error {
	return c.client.Del(ctx, key).Err()
}

// Clear clears all Redis cache
func (c *RedisCache) Clear(ctx context.Context) error {
	return c.client.FlushDB(ctx).Err()
}

// Close closes Redis connection
func (c *RedisCache) Close() error {
	return c.client.Close()
}
