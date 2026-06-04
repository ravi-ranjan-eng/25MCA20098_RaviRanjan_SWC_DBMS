SELECT 
    s.date,
    COUNT(a.date)::float / COUNT(s.date) AS acceptance_rate
FROM 
    (SELECT * FROM fb_friend_requests WHERE action = 'sent') s
LEFT JOIN 
    (SELECT * FROM fb_friend_requests WHERE action = 'accepted') a 
    ON s.user_id_sender = a.user_id_sender 
    AND s.user_id_receiver = a.user_id_receiver
GROUP BY 
    s.date
HAVING 
    COUNT(a.date) > 0;
