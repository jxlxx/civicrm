-- Seed data for survey system
-- This provides initial data needed for the survey system to function

-- Sample surveys (common CiviCRM survey types)
INSERT INTO surveys (title, description, instructions, thank_you_text, is_active) VALUES
    ('Member Satisfaction Survey', 'Annual survey to gather feedback from our members', 'Please take a few minutes to share your thoughts about our organization. Your feedback helps us improve our services.', 'Thank you for your valuable feedback! We appreciate your time and will use your responses to make improvements.', TRUE),
    ('Event Feedback Form', 'Gather feedback after events to improve future programming', 'Please share your experience at our recent event. Your feedback helps us plan better events in the future.', 'Thank you for attending our event and providing feedback! We look forward to seeing you at future events.', TRUE),
    ('Volunteer Interest Survey', 'Identify volunteer interests and skills for better placement', 'Help us understand your interests and skills so we can match you with the right volunteer opportunities.', 'Thank you for your interest in volunteering! We will contact you soon with opportunities that match your interests.', TRUE),
    ('Donor Impact Survey', 'Understand how donors want to see their impact communicated', 'Help us understand how you would like to receive updates about the impact of your donations.', 'Thank you for your generosity and feedback! We will use your input to improve our donor communications.', TRUE),
    ('Program Evaluation Survey', 'Evaluate the effectiveness of our programs and services', 'Your feedback helps us measure the impact of our programs and identify areas for improvement.', 'Thank you for helping us evaluate our programs! Your input is crucial for our continuous improvement efforts.', TRUE);

-- Sample survey questions for Member Satisfaction Survey
INSERT INTO survey_questions (survey_id, question_text, question_type, question_options, is_required, weight, help_text, is_active) VALUES
    ((SELECT id FROM surveys WHERE title = 'Member Satisfaction Survey' LIMIT 1), 'How satisfied are you with our organization overall?', 'radio', '["Very Satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very Dissatisfied"]', TRUE, 1, 'Please rate your overall satisfaction with our organization.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Member Satisfaction Survey' LIMIT 1), 'Which of our services do you use most often?', 'checkbox', '["Events", "Newsletters", "Advocacy", "Volunteer Opportunities", "Educational Resources", "Networking"]', FALSE, 2, 'Select all that apply.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Member Satisfaction Survey' LIMIT 1), 'How likely are you to recommend us to others?', 'radio', '["Very Likely", "Likely", "Neutral", "Unlikely", "Very Unlikely"]', TRUE, 3, 'Please rate how likely you are to recommend our organization.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Member Satisfaction Survey' LIMIT 1), 'What would you like to see us improve?', 'textarea', NULL, FALSE, 4, 'Please share your suggestions for improvement.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Member Satisfaction Survey' LIMIT 1), 'How did you first learn about our organization?', 'select', '["Social Media", "Website", "Friend/Family", "Event", "News Article", "Other"]', FALSE, 5, 'Please select how you first discovered us.', TRUE);

-- Sample survey questions for Event Feedback Form
INSERT INTO survey_questions (survey_id, question_text, question_type, question_options, is_required, weight, help_text, is_active) VALUES
    ((SELECT id FROM surveys WHERE title = 'Event Feedback Form' LIMIT 1), 'How would you rate the event overall?', 'radio', '["Excellent", "Good", "Fair", "Poor"]', TRUE, 1, 'Please rate your overall experience at the event.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Event Feedback Form' LIMIT 1), 'Was the event well-organized?', 'radio', '["Yes", "No", "Somewhat"]', TRUE, 2, 'Please rate the organization of the event.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Event Feedback Form' LIMIT 1), 'What did you enjoy most about the event?', 'textarea', NULL, FALSE, 3, 'Please share what you liked best.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Event Feedback Form' LIMIT 1), 'Would you attend a similar event in the future?', 'radio', '["Definitely", "Probably", "Maybe", "Probably Not", "Definitely Not"]', TRUE, 4, 'Please indicate your interest in future events.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Event Feedback Form' LIMIT 1), 'How did you hear about this event?', 'select', '["Email", "Social Media", "Website", "Friend/Family", "Newsletter", "Other"]', FALSE, 5, 'Please select how you learned about this event.', TRUE);

-- Sample survey questions for Volunteer Interest Survey
INSERT INTO survey_questions (survey_id, question_text, question_type, question_options, is_required, weight, help_text, is_active) VALUES
    ((SELECT id FROM surveys WHERE title = 'Volunteer Interest Survey' LIMIT 1), 'What areas are you most interested in volunteering?', 'checkbox', '["Administrative Support", "Event Planning", "Fundraising", "Outreach", "Education", "Technology", "Marketing", "Direct Service"]', TRUE, 1, 'Select all areas that interest you.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Volunteer Interest Survey' LIMIT 1), 'How many hours per month can you volunteer?', 'radio', '["1-5 hours", "6-10 hours", "11-20 hours", "20+ hours"]', TRUE, 2, 'Please indicate your availability.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Volunteer Interest Survey' LIMIT 1), 'What skills or experience do you have?', 'textarea', NULL, FALSE, 3, 'Please describe your relevant skills and experience.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Volunteer Interest Survey' LIMIT 1), 'When are you typically available?', 'checkbox', '["Weekdays", "Weekends", "Evenings", "Mornings", "Flexible"]', TRUE, 4, 'Select all times that work for you.', TRUE),
    ((SELECT id FROM surveys WHERE title = 'Volunteer Interest Survey' LIMIT 1), 'Do you have any special accommodations we should know about?', 'textarea', NULL, FALSE, 5, 'Please let us know if you need any accommodations.', TRUE);
