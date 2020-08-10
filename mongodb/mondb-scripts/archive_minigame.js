/**
 * created:20200810bobby.nguyen
 * run on master node
 * load to db: script.system.js
 **/
use script;
var bulkJS = db.system.js.initializeUnorderedBulkOp();
bulkJS.find({ "_id": "archiveMiniGame" }).upsert().replaceOne(
	{
		"_id": "archiveMiniGame",
		"value": (ins_active, ins_archive) => {

			// CONF values
			let cutOffDate = ((Math.floor(Date.now() / 3600000) - 24) * 3600000);
			let arrDBs = ins_active.getDB('mondb').backup_tasks.distinct('db');
			let arrCols = ins_active.getDB('mondb').backup_tasks.find({ "active": { $eq: true } }).toArray();
			let group = 'archiveMiniGame';

			// FAIL first
			if (arrDBs.length == 0 || arrCols.length == 0) { return; }

			// log START
			log('Archiving started at ' + new Date(Date.now()).toString(), group, 'Archive', 'I');

			// start archiving
			arrDBs.forEach(function (dbname) {
				// SET to current db
				let mdb = ins_active.getDB(dbname);

				arrCols.forEach(function (c) {
					if (c.db == dbname) {

						// SET source vs destination
						let colSource = mdb.getCollection(c.name);
						let colArchive = ins_archive.getDB(c.db_bk).getCollection(c.name_bk);
						let bulkArchive = colArchive.initializeUnorderedBulkOp();

						// VARs to storage docs
						var bulkUpdateIdx = [], archiveDocs = [];

						// GET docs to archive
						var query = '{"$where": "function() {return (this.' + c.archive_field + '<=new Date(' + cutOffDate.toString() + ') && this.__archive==undefined);}"}';
						archiveDocs = colSource.find(JSON.parse(query)).toArray();

						// CHECK docs to archive
						if (archiveDocs.length > 0) {
							archiveDocs.forEach(function (doc) {

								//bulkArchive.insert(doc);
								bulkArchive.find({ _id: doc._id }).upsert().replaceOne(doc);
								bulkUpdateIdx.push({
									updateMany: {
										filter: { _id: doc._id }
										, update: { $set: { '__archive.eventtime': doc[c.archive_field] } }
									}
								});
							}
							);

							try {
								// Move docs to ins_archive
								bulkArchive.execute();

								// Mark archive with TTL-index
								colSource.bulkWrite(bulkUpdateIdx, { ordered: false });
							} catch (ex) {
								// log for each archived collection
								log(ex, group, 'ARCHIVE', 'E');
							}

							// log for each archived collection
							log('Archiving from [' + c.db + '].[' + c.name + '] processed to [' + c.db_bk + '].[' + c.name_bk + '] with ' + bulkUpdateIdx.length.toString() + ' affected record(s).', group, 'ARCHIVE', 'I');
						}
					}
				});
			});

			// Log END
			log('Archiving completed at ' + new Date(Date.now()).toString(), group, 'ARCHIVE', 'I');
		}
	});
bulkJS.execute();
//create TTL indexes
db.bolatangkas_rounds.createIndex({ "__archive.eventtime": 1 }, { expireAfterSeconds: 8 * 24 * 60 * 60, name: "__archive_eventtime_01" });
db.bolatangkas_bets.createIndex({ "__archive.eventtime": 1 }, { expireAfterSeconds: 8 * 24 * 60 * 60, name: "__archive_eventtime_01" });