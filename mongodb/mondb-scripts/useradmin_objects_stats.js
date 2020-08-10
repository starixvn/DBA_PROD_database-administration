// connect to admin role
// use admin;
// var isAuth = db.auth("user","xxxxx");
// if (isAuth == 0) { quit(); }
// print("Auth is ok.");

// gather dbs stats
db.adminCommand("listDatabases").databases.forEach(function (d) {
	let mdb = db.getSiblingDB(d.name);
	let st = mdb.stats();
	let dbInfo = {
		"name": d.name,
		"creationTime": new Date(),
		"stats": {
			"sizeOnDisk": d.sizeOnDisk,
			"collections": st.collections,
			"views": st.collections,
			"objects": st.objects,
			"avgObjSize": st.avgObjSize,
			"dataSize": st.dataSize,
			"storageSize": st.storageSize,
			"numExtents": st.numExtents,
			"indexes": st.indexes,
			"indexSize": st.indexSize,
			"scaleFactor": st.scaleFactor,
			"fsUsedSize": st.fsUsedSize,
			"fsTotalSize": st.fsTotalSize,
			"operationTime": st.operationTime
		}
	};
	db.getSiblingDB("mondb").dbStats.insert(dbInfo);
});

// gather db-collections stats
db.adminCommand("listDatabases").databases.forEach(function (d) {
	let mdb = db.getSiblingDB(d.name);
	mdb.getCollectionInfos({ type: "collection" }).forEach(function (c) {
		let curCol = mdb.getCollection(c.name).stats();
		let colInfo = {
			"dbname": d.name,
			"name": c.name,
			"creationTime": new Date(),
			"stats": {
				"size": curCol.size,
				"storageSize": curCol.storageSize,
				"totalIndexSize": curCol.totalIndexSize,
				"count": curCol.count,
				"avgObjSize": curCol.avgObjSize,
				"indexSizes": curCol.indexSizes,
				"capped": curCol.capped
			}
		};

		db.getSiblingDB("mondb").colStats.insert(colInfo);
	});
});