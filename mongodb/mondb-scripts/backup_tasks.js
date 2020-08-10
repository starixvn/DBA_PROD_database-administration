/**
 * created:20200810bobby.nguyen
 * run on master node - mondb
 * load to db: mondb.backup_tasks
 **/
use mondb;
db.backup_tasks.inserMany(
    {
        "db": "minigame",
        "name": "bolatangkas_bets",
        "db_bk": "minigame_arc",
        "name_bk": "bolatangkas_bets_bk",
        "expireDay": 8,
        "archive_field": "time",
        "active": true
    },
    {
        "db": "minigame",
        "name": "bolatangkas_rounds",
        "db_bk": "minigame_arc",
        "name_bk": "bolatangkas_rounds_bk",
        "expireDay": 8,
        "archive_field": "startTime",
        "active": true
    }
);
//GO

db.grantRolesToUser(
    "lmn_archive",
    [{ role: "readWrite", db: "mondb" }]
)