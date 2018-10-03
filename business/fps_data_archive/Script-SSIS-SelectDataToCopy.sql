SELECT	dl.*
FROM		dbo.DeviceDomainLog AS dl WITH (NOLOCK)
INNER JOIN	(
	SELECT	DISTINCT
			_arc.DeviceNo
	FROM	dbo.DBA_Archive_DeviceSingleAssociation AS _arc WITH (NOLOCK)
) AS arc
		ON	dl.DeviceId = arc.DeviceNo
LEFT JOIN	FPS_DeviceFingerprint_Archive.dbo.DeviceDomainLog_bk AS bk WITH (NOLOCK)
		ON	dl.Increment = bk.Increment
WHERE	dl.Increment >= 0
	AND	bk.Increment IS NULL

SELECT	dl.*
FROM		dbo.DeviceIPLog AS dl WITH (NOLOCK)
INNER JOIN	(
	SELECT	DISTINCT
			_arc.DeviceNo
	FROM	dbo.DBA_Archive_DeviceSingleAssociation AS _arc WITH (NOLOCK)
) AS arc
		ON	dl.DeviceId = arc.DeviceNo
LEFT JOIN	FPS_DeviceFingerprint_Archive.dbo.DeviceIPLog_bk AS bk WITH (NOLOCK)
		ON	dl.Increment = bk.Increment
WHERE	dl.Increment >= 0
	AND	bk.Increment IS NULL

SELECT	d.*
FROM		dbo.Device AS d WITH (NOLOCK)
INNER JOIN	(
	SELECT	DISTINCT
			_arc.DeviceNo
	FROM	dbo.DBA_Archive_DeviceSingleAssociation AS _arc WITH (NOLOCK)
) AS arc
		ON	d.Id = arc.DeviceNo
WHERE	d.Increment >= 0