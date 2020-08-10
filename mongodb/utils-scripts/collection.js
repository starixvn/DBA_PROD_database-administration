//move collection
db.runCommand({ renameCollection: "minigame_bk.bolatangkas_rounds_bk", to: "minigame_arc.bolatangkas_rounds_bk" })

// remove column/field
db.bolatangkas_rounds.update({}, { $unset: { __archive: 1 } }, false, true);

// rename column to new name
db.bolatangkas_bets.update({ "__archiveAt": { $exists: true } }, { $rename: { "__archiveAt": "__archive" } }, false, true)

//add new column with other column's value
db.bolatangkas_rounds.find({}).forEach(function (doc) {
    doc.__archive = { "eventtime": doc.startTime };
    db.bolatangkas_rounds.save(doc);
});

// add new column with default
db.collection.update({}, { $set: { "[new_name]": [default_value] } }, { upsert: false, multi: true });