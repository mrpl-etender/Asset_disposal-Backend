class SequenceHelper {
    constructor(options) {
        this.db = options.db;
        this.sequence = options.sequence;   // HANA sequence name, e.g. 'RequestNoSeq'
        this.table = options.table;         // Fallback table name for local testing
        this.field = options.field || 'ID'; // Fallback column to MAX() over
    }

    async getNextNumber() {
        switch (this.db.kind) {
            case 'hana': {
                // Querying the sequence without an alias returns keys like "RequestNoSeq.NEXTVAL"
                const result = await this.db.run(
                    `SELECT "${this.sequence}".NEXTVAL FROM DUMMY`
                );
                
                const row = Array.isArray(result) ? result[0] : result;
                
                // Match the exact lookup key format used in your other working project
                const hanaKey = `${this.sequence}.NEXTVAL`;
                const nextVal = row[hanaKey] ?? row[hanaKey.toUpperCase()] ?? row['NEXTVAL'] ?? row['nextval'];
                
                return parseInt(nextVal, 10);
            }

            case 'sql':
            case 'sqlite': {
                // Simple MAX fallback logic for local SQLite testing
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