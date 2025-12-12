DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
   rating_id INTEGER AUTO_INCREMENT PRIMARY KEY,
   order_id  INTEGER NOT NULL,
   runner_id INTEGER NOT NULL,
   rating    TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
   rating_comment VARCHAR(255),
   rated_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO runner_ratings (order_id, runner_id, rating, rating_comment)
VALUES
   (1, 1, 5, 'Fast delivery, great service'),
    (2, 1, 4, 'Good delivery time'),
    (3, 1, 5, 'Very quick and friendly'),
    (4, 2, 3, 'Slight delay but acceptable'),
    (5, 3, 5, 'Excellent!'),
    (7, 2, 4, 'Smooth delivery'),
    (8, 2, 5, 'Super fast'),
    (10, 1, 4, 'On time and polite');