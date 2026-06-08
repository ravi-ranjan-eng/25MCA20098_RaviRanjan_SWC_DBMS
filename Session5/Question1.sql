-- SELECT * FROM user_actions;
SELECT 7 AS MONTH,
        COUNT(DISTINCT U.USER_ID) AS MONTHLY_ACTIVE_USERS
FROM USER_ACTIONS AS U
WHERE EXTRACT(MONTH FROM U.EVENT_DATE)=7
AND EXTRACT(YEAR FROM U.EVENT_DATE)=2022
AND EXISTS(
SELECT 1
FROM user_actions AS previous_month
     WHERE previous_month.user_id = U.user_id
       AND EXTRACT(MONTH FROM previous_month.event_date) = 6
    AND EXTRACT(YEAR FROM previous_month.event_date) = 2022);


        
        
        
        
        
        
        
        





