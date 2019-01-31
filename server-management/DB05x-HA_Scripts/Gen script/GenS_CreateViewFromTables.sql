--Run on full & active bodb_Licensee - DB052

declare @sqltext varchar(max)

select @sqltext = ''

select @sqltext = @sqltext + '--====== CREATE VIEW ' + name + ' ======
CREATE VIEW dbo.' + name + '
AS
SELECT * FROM DB053.bodb_Licensee.dbo.' + name + ' WITH (NOLOCK)
GO
--====== END CREATE VIEW ' + name + ' ======

'

from sysobjects where type = 'U' 
	and name not like '%DEL_%' and name not like '%test%'
order by name


select CAST(@sqltext AS XML) AS sqltext