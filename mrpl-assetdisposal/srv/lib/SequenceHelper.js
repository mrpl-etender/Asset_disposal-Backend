class SequenceHelper {
    constructor(options) {
        this.db = options.db;
        this.sequence = options.sequence;   // HANA sequence name, e.g. 'RequestNoSeq'
        this.table = options.table;         // fallback table name (DB-level, not entity name)
        this.field = options.field || 'ID'; // fallback column to MAX() over
    }

    async getNextNumber() {
        switch (this.db.kind) {
            case 'hana': {
                const result = await this.db.run(
                    `SELECT "${this.sequence}".NEXTVAL AS "NEXTVAL" FROM DUMMY`
                );
        
                const row = Array.isArray(result) ? result[0] : result;
                return parseInt(row.NEXTVAL ?? row.nextval, 10);
            }

            case 'sql':
            case 'sqlite': {
               
                // fallback column is stored as a String (e.g. RequestNo, CADANo)
                const result = await this.db.run(
                    `SELECT MAX(CAST("${this.field}" AS INTEGER)) AS "MAXVAL" FROM "${this.table}"`
                );
                const row = Array.isArray(result) ? result[0] : result;
                const max = row && row.MAXVAL != null ? parseInt(row.MAXVAL, 10) : 0;
                return (isNaN(max) ? 0 : max) + 1;
            }

            default:
                throw new Error(`Unsupported DB kind --> ${this.db.kind}`);
        }
    }
}

module.exports = SequenceHelper;