-- Custom Fields Queries
-- Provides CRUD operations and specialized queries for the custom fields system

-- Custom Groups CRUD operations
-- name: CreateCustomGroup :one
INSERT INTO custom_groups (
    name, title, extends, table_name, is_active, is_multiple, 
    collapse_display, help_pre, help_post, weight
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetCustomGroup :one
SELECT * FROM custom_groups WHERE id = $1;

-- name: GetCustomGroupByName :one
SELECT * FROM custom_groups WHERE name = $1;

-- name: ListCustomGroups :many
SELECT * FROM custom_groups 
WHERE extends = $1 AND is_active = $2
ORDER BY weight, title;

-- name: ListAllCustomGroups :many
SELECT * FROM custom_groups 
WHERE is_active = $1
ORDER BY extends, weight, title;

-- name: UpdateCustomGroup :one
UPDATE custom_groups SET
    title = $2,
    extends = $3,
    table_name = $4,
    is_active = $5,
    is_multiple = $6,
    collapse_display = $7,
    help_pre = $8,
    help_post = $9,
    weight = $10,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCustomGroup :exec
DELETE FROM custom_groups WHERE id = $1;

-- Custom Fields CRUD operations
-- name: CreateCustomField :one
INSERT INTO custom_fields (
    custom_group_id, name, label, data_type, html_type, is_required,
    is_searchable, is_search_range, is_view, is_active, weight,
    help_pre, help_post, default_value, text_length, start_date_years,
    end_date_years, date_format, time_format, option_group_id, filter, in_selector
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22
) RETURNING *;

-- name: GetCustomField :one
SELECT * FROM custom_fields WHERE id = $1;

-- name: GetCustomFieldByName :one
SELECT cf.* FROM custom_fields cf
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = $1 AND cf.name = $2;

-- name: ListCustomFieldsByGroup :many
SELECT * FROM custom_fields 
WHERE custom_group_id = $1 AND is_active = $2
ORDER BY weight, label;

-- name: ListCustomFieldsByEntity :many
SELECT cf.*, cg.name as group_name, cg.title as group_title 
FROM custom_fields cf
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.extends = $1 AND cf.is_active = $2 AND cg.is_active = $3
ORDER BY cg.weight, cg.title, cf.weight, cf.label;

-- name: UpdateCustomField :one
UPDATE custom_fields SET
    label = $2,
    data_type = $3,
    html_type = $4,
    is_required = $5,
    is_searchable = $6,
    is_search_range = $7,
    is_view = $8,
    is_active = $9,
    weight = $10,
    help_pre = $11,
    help_post = $12,
    default_value = $13,
    text_length = $14,
    start_date_years = $15,
    end_date_years = $16,
    date_format = $17,
    time_format = $18,
    option_group_id = $19,
    filter = $20,
    in_selector = $21,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCustomField :exec
DELETE FROM custom_fields WHERE id = $1;

-- Custom Field Options CRUD operations
-- name: CreateCustomFieldOption :one
INSERT INTO custom_field_options (
    custom_field_id, label, value, weight, is_active
) VALUES ($1, $2, $3, $4, $5) RETURNING *;

-- name: GetCustomFieldOption :one
SELECT * FROM custom_field_options WHERE id = $1;

-- name: ListCustomFieldOptions :many
SELECT * FROM custom_field_options 
WHERE custom_field_id = $1 AND is_active = $2
ORDER BY weight, label;

-- name: UpdateCustomFieldOption :one
UPDATE custom_field_options SET
    label = $2,
    value = $3,
    weight = $4,
    is_active = $5
WHERE id = $1 RETURNING *;

-- name: DeleteCustomFieldOption :exec
DELETE FROM custom_field_options WHERE id = $1;

-- Custom Values CRUD operations
-- name: CreateCustomValue :one
INSERT INTO custom_values (
    custom_field_id, entity_table, entity_id, value_text, value_int,
    value_float, value_date, value_boolean, value_link
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetCustomValue :one
SELECT * FROM custom_values WHERE id = $1;

-- name: GetCustomValuesByEntity :many
SELECT cv.*, cf.name as field_name, cf.label as field_label, cf.data_type, cf.html_type,
       cg.name as group_name, cg.title as group_title
FROM custom_values cv
INNER JOIN custom_fields cf ON cv.custom_field_id = cf.id
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cv.entity_table = $1 AND cv.entity_id = $2
ORDER BY cg.weight, cg.title, cf.weight, cf.label;

-- name: GetCustomValueByField :one
SELECT * FROM custom_values 
WHERE custom_field_id = $1 AND entity_table = $2 AND entity_id = $3;

-- name: UpdateCustomValue :one
UPDATE custom_values SET
    value_text = $4,
    value_int = $5,
    value_float = $6,
    value_date = $7,
    value_boolean = $8,
    value_link = $9,
    updated_at = NOW()
WHERE custom_field_id = $1 AND entity_table = $2 AND entity_id = $3 RETURNING *;

-- name: DeleteCustomValue :exec
DELETE FROM custom_values WHERE id = $1;

-- name: DeleteCustomValuesByEntity :exec
DELETE FROM custom_values WHERE entity_table = $1 AND entity_id = $2;

-- Specialized queries for custom fields
-- name: GetCustomFieldsForContact :many
SELECT cf.*, cg.title as group_title, cg.help_pre as group_help_pre, cg.help_post as group_help_post
FROM custom_fields cf
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.extends = 'Contact' AND cf.is_active = $1 AND cg.is_active = $2
ORDER BY cg.weight, cg.title, cf.weight, cf.label;

-- name: GetCustomFieldsForContribution :many
SELECT cf.*, cg.title as group_title, cg.help_pre as group_help_pre, cg.help_post as group_help_post
FROM custom_fields cf
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.extends = 'Contribution' AND cf.is_active = $1 AND cg.is_active = $2
ORDER BY cg.weight, cg.title, cf.weight, cf.label;

-- name: GetCustomFieldsForEvent :many
SELECT cf.*, cg.title as group_title, cg.help_pre as group_help_pre, cg.help_post as group_help_post
FROM custom_fields cf
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.extends = 'Event' AND cf.is_active = $1 AND cg.is_active = $2
ORDER BY cg.weight, cg.title, cf.weight, cf.label;

-- name: GetCustomFieldsForActivity :many
SELECT cf.*, cg.title as group_title, cg.help_pre as group_help_pre, cg.help_post as group_help_post
FROM custom_fields cf
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.extends = 'Activity' AND cf.is_active = $1 AND cg.is_active = $2
ORDER BY cg.weight, cg.title, cf.weight, cf.label;

-- Search queries for custom fields
-- name: SearchCustomValues :many
SELECT cv.*, cf.name as field_name, cf.label as field_label, cf.data_type,
       cg.title as group_title, cg.extends
FROM custom_values cv
INNER JOIN custom_fields cf ON cv.custom_field_id = cf.id
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cv.entity_table = $1 
  AND cv.entity_id = $2
  AND cf.is_searchable = $3
ORDER BY cg.weight, cf.weight;

-- name: CountCustomValuesByEntity :one
SELECT COUNT(*) FROM custom_values 
WHERE entity_table = $1 AND entity_id = $2;

-- name: CountCustomFieldsByGroup :one
SELECT COUNT(*) FROM custom_fields 
WHERE custom_group_id = $1 AND is_active = $2;
