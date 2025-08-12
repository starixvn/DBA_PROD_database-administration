SELECT * FROM n8n_FlowSchedule nfs
SELECT * FROM n8n_CookiesLogin ncl

SELECT * FROM HRM_LeaveLog hll
SELECT * FROM HRM_LeaveLog_Realtime hll
SELECT * FROM HRM_AttendanceLog

SELECT * FROM n8n_GoogleCalandar_Realtime ngcr
SELECT * FROM n8n_GoogleCalandar ngc

-- =========

SELECT * FROM Rocketor_DeployRequest 
SELECT * FROM Rocketor_DeployRequestAlert rdra 

------------------

SELECT 'GoogleCalandar' AS sites , MAX(RunTime) AS RunTime FROM n8n_GoogleCalandar_Realtime
UNION ALL 
SELECT 'Leave', MAX(RunTime) FROM HRM_LeaveLog_Realtime
UNION ALL 
SELECT 'Attendance', MAX(RunTime) FROM HRM_AttendanceLog
UNION ALL 
SELECT 'Rocketor', MAX(rdr.RunTimeAt) FROM Rocketor_DeployRequest rdr


--- 
SELECT 'GoogleCalandar' AS sites , MAX(RunTime) as RunTime FROM n8n_GoogleCalandar_Realtime
UNION ALL 
SELECT 'Leave', MAX(RunTime) FROM LeaveLog_Realtime
UNION ALL 
SELECT 'Attendance', MAX(RunTime) FROM AttendanceLog
UNION ALL 
SELECT 'Rocketor', MAX(rdr.RunTimeAt) FROM DeploymentRequestTmp rdr

SELECT   * FROM n8n_FlowSchedule nfs