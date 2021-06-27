INSERT INTO subs
  (subs_name, subs_email, subs_birthday)
VALUES
  (?, ?, ?)
ON DUPLICATE KEY UPDATE
  subs_name     = VALUES(subs_name),
  subs_birthday = VALUES(subs_birthday)