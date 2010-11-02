

local keywords = {}

local function index(t)
	local rt = {}
	for i=1,#t do
		rt[t[i]] = true
	end
	return rt
end

local function copy(src, dest)
	for k,v in pairs(src) do
		dest[k] = v
	end
	return dest
end

local function remove(src, dest)
	for k,v in pairs(src) do
		dest[k] = nil
	end
	return dest
end


--source: http://developer.mimer.com/validator/sql-reserved-words.tml
keywords['SQL-92'] = index{
	'ABSOLUTE', 'ACTION', 'ADD', 'ALL', 'ALLOCATE', 'ALTER', 'AND', 'ANY', 'ARE',
	'AS', 'ASC', 'ASSERTION', 'AT', 'AUTHORIZATION', 'AVG', 'BEGIN', 'BETWEEN',
	'BIT', 'BIT_LENGTH', 'BOTH', 'BY', 'CALL', 'CASCADE', 'CASCADED', 'CASE',
	'CAST', 'CATALOG', 'CHAR', 'CHAR_LENGTH', 'CHARACTER', 'CHARACTER_LENGTH',
	'CHECK', 'CLOSE', 'COALESCE', 'COLLATE', 'COLLATION', 'COLUMN', 'COMMIT',
	'CONDITION', 'CONNECT', 'CONNECTION', 'CONSTRAINT', 'CONSTRAINTS', 'CONTAINS',
	'CONTINUE', 'CONVERT', 'CORRESPONDING', 'COUNT', 'CREATE', 'CROSS', 'CURRENT',
	'CURRENT_DATE', 'CURRENT_PATH', 'CURRENT_TIME', 'CURRENT_TIMESTAMP',
	'CURRENT_USER', 'CURSOR', 'DATE', 'DAY', 'DEALLOCATE', 'DEC', 'DECIMAL',
	'DECLARE', 'DEFAULT', 'DEFERRABLE', 'DEFERRED', 'DELETE', 'DESC', 'DESCRIBE',
	'DESCRIPTOR', 'DETERMINISTIC', 'DIAGNOSTICS', 'DISCONNECT', 'DISTINCT', 'DO',
	'DOMAIN', 'DOUBLE', 'DROP', 'ELSE', 'ELSEIF', 'END', 'ESCAPE', 'EXCEPT',
	'EXCEPTION', 'EXEC', 'EXECUTE', 'EXISTS', 'EXIT', 'EXTERNAL', 'EXTRACT',
	'FALSE', 'FETCH', 'FIRST', 'FLOAT', 'FOR', 'FOREIGN', 'FOUND', 'FROM', 'FULL',
	'FUNCTION', 'GET', 'GLOBAL', 'GO', 'GOTO', 'GRANT', 'GROUP', 'HANDLER', 'HAVING',
	'HOUR', 'IDENTITY', 'IF', 'IMMEDIATE', 'IN', 'INDICATOR', 'INITIALLY', 'INNER',
	'INOUT', 'INPUT', 'INSENSITIVE', 'INSERT', 'INT', 'INTEGER', 'INTERSECT',
	'INTERVAL', 'INTO', 'IS', 'ISOLATION', 'JOIN', 'KEY', 'LANGUAGE', 'LAST',
	'LEADING', 'LEAVE', 'LEFT', 'LEVEL', 'LIKE', 'LOCAL', 'LOOP', 'LOWER', 'MATCH',
	'MAX', 'MIN', 'MINUTE', 'MODULE', 'MONTH', 'NAMES', 'NATIONAL', 'NATURAL',
	'NCHAR', 'NEXT', 'NO', 'NOT', 'NULL', 'NULLIF', 'NUMERIC', 'OCTET_LENGTH', 'OF',
	'ON', 'ONLY', 'OPEN', 'OPTION', 'OR', 'ORDER', 'OUT', 'OUTER', 'OUTPUT',
	'OVERLAPS', 'PAD', 'PARAMETER', 'PARTIAL', 'PATH', 'POSITION', 'PRECISION',
	'PREPARE', 'PRESERVE', 'PRIMARY', 'PRIOR', 'PRIVILEGES', 'PROCEDURE', 'PUBLIC',
	'READ', 'REAL', 'REFERENCES', 'RELATIVE', 'REPEAT', 'RESIGNAL', 'RESTRICT',
	'RETURN', 'RETURNS', 'REVOKE', 'RIGHT', 'ROLLBACK', 'ROUTINE', 'ROWS', 'SCHEMA',
	'SCROLL', 'SECOND', 'SECTION', 'SELECT', 'SESSION', 'SESSION_USER', 'SET',
	'SIGNAL', 'SIZE', 'SMALLINT', 'SOME', 'SPACE', 'SPECIFIC', 'SQL', 'SQLCODE',
	'SQLERROR', 'SQLEXCEPTION', 'SQLSTATE', 'SQLWARNING', 'SUBSTRING', 'SUM',
	'SYSTEM_USER', 'TABLE', 'TEMPORARY', 'THEN', 'TIME', 'TIMESTAMP',
	'TIMEZONE_HOUR', 'TIMEZONE_MINUTE', 'TO', 'TRAILING', 'TRANSACTION', 'TRANSLATE',
	'TRANSLATION', 'TRIM', 'TRUE', 'UNDO', 'UNION', 'UNIQUE', 'UNKNOWN', 'UNTIL',
	'UPDATE', 'UPPER', 'USAGE', 'USER', 'USING', 'VALUE', 'VALUES', 'VARCHAR',
	'VARYING', 'VIEW', 'WHEN', 'WHENEVER', 'WHERE', 'WHILE', 'WITH', 'WORK',
	'WRITE', 'YEAR', 'ZONE',
}

keywords['SQL-99'] = index{
	'ABSOLUTE', 'ACTION', 'ADD', 'AFTER', 'ALL', 'ALLOCATE', 'ALTER', 'AND', 'ANY',
	'ARE', 'ARRAY', 'AS', 'ASC', 'ASENSITIVE', 'ASSERTION', 'ASYMMETRIC', 'AT',
	'ATOMIC', 'AUTHORIZATION', 'BEFORE', 'BEGIN', 'BETWEEN', 'BINARY', 'BIT',
	'BLOB', 'BOOLEAN', 'BOTH', 'BREADTH', 'BY', 'CALL', 'CASCADE', 'CASCADED',
	'CASE', 'CAST', 'CATALOG', 'CHAR', 'CHARACTER', 'CHECK', 'CLOB', 'CLOSE',
	'COLLATE', 'COLLATION', 'COLUMN', 'COMMIT', 'CONDITION', 'CONNECT',
	'CONNECTION', 'CONSTRAINT', 'CONSTRAINTS', 'CONSTRUCTOR', 'CONTINUE',
	'CORRESPONDING', 'CREATE', 'CROSS', 'CUBE', 'CURRENT', 'CURRENT_DATE',
	'CURRENT_DEFAULT_TRANSFORM_GROUP', 'CURRENT_PATH', 'CURRENT_ROLE',
	'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_TRANSFORM_GROUP_FOR_TYPE',
	'CURRENT_USER', 'CURSOR', 'CYCLE', 'DATA', 'DATE', 'DAY', 'DEALLOCATE', 'DEC',
	'DECIMAL', 'DECLARE', 'DEFAULT', 'DEFERRABLE', 'DEFERRED', 'DELETE', 'DEPTH',
	'DEREF', 'DESC', 'DESCRIBE', 'DESCRIPTOR', 'DETERMINISTIC', 'DIAGNOSTICS',
	'DISCONNECT', 'DISTINCT', 'DO', 'DOMAIN', 'DOUBLE', 'DROP', 'DYNAMIC', 'EACH',
	'ELSE', 'ELSEIF', 'END', 'EQUALS', 'ESCAPE', 'EXCEPT', 'EXCEPTION', 'EXEC',
	'EXECUTE', 'EXISTS', 'EXIT', 'EXTERNAL', 'FALSE', 'FETCH', 'FILTER', 'FIRST',
	'FLOAT', 'FOR', 'FOREIGN', 'FOUND', 'FREE', 'FROM', 'FULL', 'FUNCTION',
	'GENERAL', 'GET', 'GLOBAL', 'GO', 'GOTO', 'GRANT', 'GROUP', 'GROUPING',
	'HANDLER', 'HAVING', 'HOLD', 'HOUR', 'IDENTITY', 'IF', 'IMMEDIATE', 'IN',
	'INDICATOR', 'INITIALLY', 'INNER', 'INOUT', 'INPUT', 'INSENSITIVE', 'INSERT',
	'INT', 'INTEGER', 'INTERSECT', 'INTERVAL', 'INTO', 'IS', 'ISOLATION',
	'ITERATE', 'JOIN', 'KEY', 'LANGUAGE', 'LARGE', 'LAST', 'LATERAL', 'LEADING',
	'LEAVE', 'LEFT', 'LEVEL', 'LIKE', 'LOCAL', 'LOCALTIME', 'LOCALTIMESTAMP',
	'LOCATOR', 'LOOP', 'MAP', 'MATCH', 'METHOD', 'MINUTE', 'MODIFIES', 'MODULE',
	'MONTH', 'NAMES', 'NATIONAL', 'NATURAL', 'NCHAR', 'NCLOB', 'NEW', 'NEXT', 'NO',
	'NONE', 'NOT', 'NULL', 'NUMERIC', 'OBJECT', 'OF', 'OLD', 'ON', 'ONLY', 'OPEN',
	'OPTION', 'OR', 'ORDER', 'ORDINALITY', 'OUT', 'OUTER', 'OUTPUT', 'OVER',
	'OVERLAPS', 'PAD', 'PARAMETER', 'PARTIAL', 'PARTITION', 'PATH', 'PRECISION',
	'PREPARE', 'PRESERVE', 'PRIMARY', 'PRIOR', 'PRIVILEGES', 'PROCEDURE', 'PUBLIC',
	'RANGE', 'READ', 'READS', 'REAL', 'RECURSIVE', 'REF', 'REFERENCES',
	'REFERENCING', 'RELATIVE', 'RELEASE', 'REPEAT', 'RESIGNAL', 'RESTRICT',
	'RESULT', 'RETURN', 'RETURNS', 'REVOKE', 'RIGHT', 'ROLE', 'ROLLBACK', 'ROLLUP',
	'ROUTINE', 'ROW', 'ROWS', 'SAVEPOINT', 'SCHEMA', 'SCOPE', 'SCROLL', 'SEARCH',
	'SECOND', 'SECTION', 'SELECT', 'SENSITIVE', 'SESSION', 'SESSION_USER', 'SET',
	'SETS', 'SIGNAL', 'SIMILAR', 'SIZE', 'SMALLINT', 'SOME', 'SPACE', 'SPECIFIC',
	'SPECIFICTYPE', 'SQL', 'SQLEXCEPTION', 'SQLSTATE', 'SQLWARNING', 'START',
	'STATE', 'STATIC', 'SYMMETRIC', 'SYSTEM', 'SYSTEM_USER', 'TABLE',
	'TEMPORARY', 'THEN', 'TIME', 'TIMESTAMP', 'TIMEZONE_HOUR', 'TIMEZONE_MINUTE',
	'TO', 'TRAILING', 'TRANSACTION', 'TRANSLATION', 'TREAT', 'TRIGGER', 'TRUE',
	'UNDER', 'UNDO', 'UNION', 'UNIQUE', 'UNKNOWN', 'UNNEST', 'UNTIL', 'UPDATE',
	'USAGE', 'USER', 'USING', 'VALUE', 'VALUES', 'VARCHAR', 'VARYING', 'VIEW',
	'WHEN', 'WHENEVER', 'WHERE', 'WHILE', 'WINDOW', 'WITH', 'WITHIN', 'WITHOUT',
	'WORK', 'WRITE', 'YEAR', 'ZONE',
}

keywords['SQL-2003'] = index{
	'ADD', 'ALL', 'ALLOCATE', 'ALTER', 'AND', 'ANY', 'ARE', 'ARRAY', 'AS',
	'ASENSITIVE', 'ASYMMETRIC', 'AT', 'ATOMIC', 'AUTHORIZATION', 'BEGIN',
	'BETWEEN', 'BIGINT', 'BINARY', 'BLOB', 'BOOLEAN', 'BOTH', 'BY', 'CALL',
	'CALLED', 'CASCADED', 'CASE', 'CAST', 'CHAR', 'CHARACTER', 'CHECK', 'CLOB',
	'CLOSE', 'COLLATE', 'COLUMN', 'COMMIT', 'CONDITION', 'CONNECT', 'CONSTRAINT',
	'CONTINUE', 'CORRESPONDING', 'CREATE', 'CROSS', 'CUBE', 'CURRENT',
	'CURRENT_DATE', 'CURRENT_DEFAULT_TRANSFORM_GROUP', 'CURRENT_PATH',
	'CURRENT_ROLE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP',
	'CURRENT_TRANSFORM_GROUP_FOR_TYPE', 'CURRENT_USER', 'CURSOR', 'CYCLE', 'DATE',
	'DAY', 'DEALLOCATE', 'DEC', 'DECIMAL', 'DECLARE', 'DEFAULT', 'DELETE', 'DEREF',
	'DESCRIBE', 'DETERMINISTIC', 'DISCONNECT', 'DISTINCT', 'DO', 'DOUBLE', 'DROP',
	'DYNAMIC', 'EACH', 'ELEMENT', 'ELSE', 'ELSEIF', 'END', 'ESCAPE', 'EXCEPT',
	'EXEC', 'EXECUTE', 'EXISTS', 'EXIT', 'EXTERNAL', 'FALSE', 'FETCH', 'FILTER',
	'FLOAT', 'FOR', 'FOREIGN', 'FREE', 'FROM', 'FULL', 'FUNCTION', 'GET', 'GLOBAL',
	'GRANT', 'GROUP', 'GROUPING', 'HANDLER', 'HAVING', 'HOLD', 'HOUR', 'IDENTITY',
	'IF', 'IMMEDIATE', 'IN', 'INDICATOR', 'INNER', 'INOUT', 'INPUT', 'INSENSITIVE',
	'INSERT', 'INT', 'INTEGER', 'INTERSECT', 'INTERVAL', 'INTO', 'IS', 'ITERATE',
	'JOIN', 'LANGUAGE', 'LARGE', 'LATERAL', 'LEADING', 'LEAVE', 'LEFT', 'LIKE',
	'LOCAL', 'LOCALTIME', 'LOCALTIMESTAMP', 'LOOP', 'MATCH', 'MEMBER', 'MERGE',
	'METHOD', 'MINUTE', 'MODIFIES', 'MODULE', 'MONTH', 'MULTISET', 'NATIONAL',
	'NATURAL', 'NCHAR', 'NCLOB', 'NEW', 'NO', 'NONE', 'NOT', 'NULL', 'NUMERIC',
	'OF', 'OLD', 'ON', 'ONLY', 'OPEN', 'OR', 'ORDER', 'OUT', 'OUTER', 'OUTPUT',
	'OVER', 'OVERLAPS', 'PARAMETER', 'PARTITION', 'PRECISION', 'PREPARE', 'PRIMARY',
	'PROCEDURE', 'RANGE', 'READS', 'REAL', 'RECURSIVE', 'REF', 'REFERENCES',
	'REFERENCING', 'RELEASE', 'REPEAT', 'RESIGNAL', 'RESULT', 'RETURN', 'RETURNS',
	'REVOKE', 'RIGHT', 'ROLLBACK', 'ROLLUP', 'ROW', 'ROWS', 'SAVEPOINT', 'SCOPE',
	'SCROLL', 'SEARCH', 'SECOND', 'SELECT', 'SENSITIVE', 'SESSION_USER', 'SET',
	'SIGNAL', 'SIMILAR', 'SMALLINT', 'SOME', 'SPECIFIC', 'SPECIFICTYPE', 'SQL',
	'SQLEXCEPTION', 'SQLSTATE', 'SQLWARNING', 'START', 'STATIC', 'SUBMULTISET',
	'SYMMETRIC', 'SYSTEM', 'SYSTEM_USER', 'TABLE', 'TABLESAMPLE', 'THEN', 'TIME',
	'TIMESTAMP', 'TIMEZONE_HOUR', 'TIMEZONE_MINUTE', 'TO', 'TRAILING',
	'TRANSLATION', 'TREAT', 'TRIGGER', 'TRUE', 'UNDO', 'UNION', 'UNIQUE',
	'UNKNOWN', 'UNNEST', 'UNTIL', 'UPDATE', 'USER', 'USING', 'VALUE', 'VALUES',
	'VARCHAR', 'VARYING', 'WHEN', 'WHENEVER', 'WHERE', 'WHILE', 'WINDOW', 'WITH',
	'WITHIN', 'WITHOUT', 'YEAR',
}

--source: http://www.ibphoenix.com/downloads/60LangRef.zip, Appendix A
keywords['Interbase 6.0'] = index{
	'ACTION', 'ADMIN', 'ALTER', 'AS', 'AT', 'AVG', 'BASE_NAME', 'BETWEEN', 'BUFFER',
	'CASCADE', 'CHARACTER', 'CHECK', 'COLLATE', 'COMMIT', 'COMPUTED', 'CONNECT',
	'CONTINUE', 'CSTRING', 'CURRENT_TIME', 'DATABASE', 'DB_KEY', 'DECIMAL', 'DELETE',
	'DESCRIBE', 'ACTIVE', 'AFTER', 'AND', 'ASC', 'AUTO', 'BASED', 'BEFORE', 'BLOB',
	'BY', 'CAST', 'CHARACTER_LENGTH', 'CHECK_POINT_LEN', 'COLLATION', 'COMMITTED',
	'CLOSE', 'CONSTRAINT', 'COUNT', 'CURRENT', 'CURRENT_TIMESTAMP', 'DATE', 'DEBUG',
	'DECLARE', 'DESC', 'DESCRIPTOR', 'ADD', 'ALL', 'ANY', 'ASCENDING', 'AUTODDL',
	'BASENAME', 'BEGIN', 'BLOBEDIT', 'CACHE', 'CHAR', 'CHAR_LENGTH', 'CHECK_POINT_LENGTH',
	'COLUMN', 'COMPILETIME', 'CONDITIONAL', 'CONTAINING', 'CREATE', 'CURRENT_DATE',
	'CURSOR', 'DAY', 'DEC', 'DEFAULT', 'DESCENDING', 'DISCONNECT', 'DISPLAY', 'DOMAIN',
	'ECHO', 'END', 'EVENT', 'EXISTS', 'EXTERNAL', 'FILE', 'FOR', 'FREE_IT', 'FUNCTION',
	'GEN_ID', 'GRANT', 'GROUP_COMMIT_', 'HELP', 'IMMEDIATE', 'INDEX', 'INNER', 'INSERT',
	'INTO', 'ISQL', 'LC_MESSAGES', 'LENGTH', 'LIKE', 'LOG_BUF_SIZE', 'DISTINCT', 'DOUBLE',
	'EDIT', 'ENTRY_POINT', 'EXCEPTION', 'EXIT', 'EXTRACT', 'FILTER', 'FOREIGN', 'FROM',
	'GDSCODE', 'GLOBAL', 'GROUP', 'WAIT_TIME', 'HOUR', 'IN', 'INDICATOR', 'INPUT', 'INT',
	'IS', 'JOIN', 'LC_TYPE', 'LEV', 'LOGFILE', 'LONG', 'DO', 'DROP', 'ELSE', 'ESCAPE',
	'EXECUTE', 'EXTERN', 'FETCH', 'FLOAT', 'FOUND', 'FULL', 'GENERATOR', 'GOTO',
	'GROUP_COMMIT_WAIT', 'HAVING', 'IF', 'INACTIVE', 'INIT', 'INPUT_TYPE', 'INTEGER',
	'ISOLATION', 'KEY', 'LEFT', 'LEVEL', 'LOG_BUFFER_SIZE', 'MANUAL', 'MAX', 'MAX_SEGMENT',
	'MIN', 'MODULE_NAME', 'NATIONAL', 'NO', 'NULL', 'NUM_LOG_BUFFERS', 'ON', 'OPTION',
	'OUTER', 'OVERFLOW', 'PAGES', 'PASSWORD', 'POST_EVENT', 'PROCEDURE', 'PRIVILEGES',
	'RAW_PARTITIONS', 'REAL', 'RELEASE', 'RESTRICT', 'RETURNING_VALUES', 'RIGHT',
	'RUNTIME', 'SEGMENT', 'MAXIMUM', 'MERGE', 'MINIMUM', 'MONTH', 'NATURAL', 'NOAUTO',
	'NUMERIC', 'OCTET_LENGTH', 'ONLY', 'OR', 'OUTPUT', 'PAGE', 'PAGE_SIZE', 'PLAN',
	'PRECISION', 'PROTECTED', 'PUBLIC', 'RDB$DB_KEY', 'RECORD_VERSION', 'RESERV',
	'RETAIN', 'RETURNS', 'ROLE', 'SCHEMA', 'SELECT', 'MAXIMUM_SEGMENT', 'MESSAGE',
	'MINUTE', 'NAMES', 'NCHAR', 'NOT', 'NUM_LOG_BUFS', 'OF', 'OPEN', 'ORDER',
	'OUTPUT_TYPE', 'PAGELENGTH', 'PARAMETER', 'POSITION', 'PREPARE', 'PRIMARY',
	'QUIT', 'READ', 'REFERENCES', 'RESERVING', 'RETURN', 'REVOKE', 'ROLLBACK', 'SECOND',
	'SET', 'SHADOW', 'SHOW', 'SMALLINT', 'SORT', 'SQLWARNING', 'STARTS', 'STATISTICS',
	'SUSPEND', 'THEN', 'TO', 'TRANSLATION', 'TYPE', 'UNIQUE', 'USER', 'VALUES',
	'VARYING', 'WAIT', 'WHENEVER', 'WITH', 'YEAR', 'SHARED', 'SINGULAR', 'SNAPSHOT',
	'SQLCODE', 'STABILITY', 'STATEMENT', 'SUB_TYPE', 'TABLE', 'TIME', 'TRANSACTION',
	'TRIGGER', 'UNCOMMITTED', 'UPDATE', 'USING', 'VARCHAR', 'VERSION', 'WEEKDAY',
	'WHERE', 'WORK', 'YEARDAY', 'SHELL', 'SIZE', 'SOME', 'SQLERROR', 'STARTING',
	'STATIC', 'SUM', 'TERMINATOR', 'TIMESTAMP', 'TRANSLATE', 'TRIM', 'UNION', 'UPPER',
	'VALUE', 'VARIABLE', 'VIEW', 'WHEN', 'WHILE', 'WRITE',
}

--source: http://firebirdsql.org/refdocs/langrefupd15-reswords.html
--verified with http://www.firebirdsql.org/rlsnotesh/rlsnotes15.html#sql-reswords
keywords['Interbase 6.5'] = copy(keywords['Interbase 6.0'], index{ --from fb 1.0 relnotes
	'PERCENT', 'ROWS', 'TIES',
})

keywords['Interbase 7'] = copy(keywords['Interbase 6.5'], index{ --from fb 1.5 relnotes
	'BOOLEAN', 'FALSE', 'GLOBAL', 'PRESERVE', 'TEMPORARY', 'TRUE',
})

keywords['Firebird 1.0'] = copy(keywords['Interbase 6.0'], index{
	--added as reserved
	'BREAK', 'CURRENT_ROLE', 'CURRENT_USER', 'DESCRIPTOR', 'FIRST',
	'RECREATE', 'SKIP', 'SUBSTRING',
})

keywords['Firebird 1.5'] = remove(index{
	--no longer reserved
	'BREAK', 'DESCRIPTOR', 'FIRST', 'SKIP', 'SUBSTRING',
	--added as non-reserved
	'COALESCE', 'DELETING', 'INSERTING', 'LAST', 'LEAVE', 'LOCK', 'NULLIF',
	'NULLS', 'STATEMENT', 'UPDATING', 'USING'
}, copy(keywords['Firebird 1.0'], index{
	--added as reserved
	'BIGINT', 'CASE', 'CURRENT_CONNECTION',
	'CURRENT_TRANSACTION', 'RELEASE', 'ROW_COUNT', 'SAVEPOINT',
}))

--source: http://www.firebirdsql.org/refdocs/langrefupd20-reskeywords.html
--verified with http://www.firebirdsql.org/rlsnotesh/rlsnotes20.html#rnfbtwo-reswords
keywords['Firebird 2.0'] = remove(index{
	--added as non-reserved
	'BACKUP', 'BLOCK', 'COALESCE', 'COLLATION', 'COMMENT', 'DELETING', 'DIFFERENCE',
	'IIF', 'INSERTING', 'LAST', 'LEAVE', 'LOCK', 'NEXT', 'NULLIF', 'NULLS', 'RESTART',
	'RETURNING', 'SCALAR_ARRAY', 'SEQUENCE', 'STATEMENT', 'UPDATING',
	--no longer reserved
	'ACTION', 'CASCADE', 'FREE_IT', 'RESTRICT', 'ROLE', 'TYPE', 'WEEKDAY', 'YEARDAY',
	--no longer keywords
	'BASENAME', 'CACHE', 'CHECK_POINT_LEN', 'GROUP_COMMIT_WAIT', 'LOG_BUF_SIZE',
	'LOGFILE', 'NUM_LOG_BUFS', 'RAW_PARTITIONS',
}, copy(keywords['Interbase 6.0'], index{
	--added as reserved
	'BIGINT', 'BIT_LENGTH', 'BOTH', 'CASE', 'CHAR_LENGTH', 'CHARACTER_LENGTH',
	'CLOSE', 'CROSS', 'CURRENT_CONNECTION', 'CURRENT_ROLE', 'CURRENT_TRANSACTION',
	'CURRENT_USER', 'FETCH', 'LEADING', 'LOWER', 'OCTET_LENGTH', 'OPEN', 'RECREATE',
	'RELEASE', 'ROW_COUNT', 'ROWS', 'SAVEPOINT', 'TRAILING', 'TRIM', 'USING'
}))

--source: http://www.firebirdsql.org/rlsnotesh/rlsnotes210.html#rnfb20x-reswords
--also see http://www.firebirdsql.org/refdocs/langrefupd21-reskeywords.html
keywords['Firebird 2.1'] = remove(index{
	--added as non-reserved
	'ABS', 'ACCENT', 'ACOS', 'ALWAYS', 'ASCII_CHAR', 'ASCII_VAL', 'ASIN', 'ATAN',
	'ATAN2', 'BIN_AND', 'BIN_OR', 'BIN_SHL', 'BIN_SHR', 'BIN_XOR', 'CEIL',
	'CEILING', 'COS', 'COSH', 'COT', 'DATEADD', 'DATEDIFF', 'DECODE', 'EXP',
	'FLOOR', 'GEN_UUID', 'GENERATED', 'HASH', 'LIST', 'LN', 'LOG', 'LOG10',
	'LPAD', 'MATCHED', 'MATCHING', 'MAXVALUE', 'MILLISECOND', 'MINVALUE', 'MOD',
	'OVERLAY', 'PAD', 'PI', 'PLACING', 'POWER', 'PRESERVE', 'RAND', 'REPLACE',
	'REVERSE', 'ROUND', 'RPAD', 'SIGN', 'SIN', 'SINH', 'SPACE', 'SQRT', 'TAN',
	'TANH', 'TEMPORARY', 'TRUNC', 'WEEK',
}, copy(keywords['Firebird 2.0'], index{
	--added as reserved
	'CONNECT', 'DISCONNECT', 'GLOBAL', 'INSENSITIVE',
	'RECURSIVE', 'SENSITIVE', 'START',
}))

--as given in firebird-devel mailing list (presumably SQL-2008 draft at some moment)
--TODO: update this with the 2010 draft at http://www.wiscorp.com/SQLStandards.html
keywords['SQL-2008 Draft'] = index{
	'ABS', 'ALL', 'ALLOCATE', 'ALTER', 'AND', 'ANY', 'ARE', 'ARRAY', 'ARRAY_AGG',
	'AS', 'ASENSITIVE', 'ASYMMETRIC', 'AT', 'ATOMIC', 'AUTHORIZATION', 'AVG', 'BEGIN',
	'BETWEEN', 'BIGINT', 'BINARY', 'BLOB', 'BOOLEAN', 'BOTH', 'BY', 'CALL', 'CALLED',
	'CARDINALITY', 'CASCADED', 'CASE', 'CAST', 'CEIL', 'CEILING', 'CHAR', 'CHAR_LENGTH',
	'CHARACTER', 'CHARACTER_LENGTH', 'CHECK', 'CLOB', 'CLOSE', 'COALESCE', 'COLLATE',
	'COLLECT', 'COLUMN', 'COMMIT', 'CONDITION', 'CONNECT', 'CONSTRAINT', 'CONVERT',
	'CORR', 'CORRESPONDING', 'COUNT', 'COVAR_POP', 'COVAR_SAMP', 'CREATE', 'CROSS',
	'CUBE', 'CUME_DIST', 'CURRENT', 'CURRENT_CATALOG', 'CURRENT_DATE',
	'CURRENT_DEFAULT_TRANSFORM_GROUP', 'CURRENT_PATH', 'CURRENT_ROLE', 'CURRENT_SCHEMA',
	'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_TRANSFORM_GROUP_FOR_TYPE', 'CURRENT_USER',
	'CURSOR', 'CYCLE', 'DATE', 'DAY', 'DEALLOCATE', 'DEC', 'DECIMAL', 'DECLARE', 'DEFAULT',
	'DELETE', 'DENSE_RANK', 'DEREF', 'DESCRIBE', 'DETERMINISTIC', 'DISCONNECT', 'DISTINCT',
	'DOUBLE', 'DROP', 'DYNAMIC', 'EACH', 'ELEMENT', 'ELSE', 'END', 'END_EXEC', 'ESCAPE',
	'EVERY', 'EXCEPT', 'EXEC', 'EXECUTE', 'EXISTS', 'EXP', 'EXTERNAL', 'EXTRACT', 'FALSE',
	'FETCH', 'FILTER', 'FIRST_VALUE', 'FLOAT', 'FLOOR', 'FOR', 'FOREIGN', 'FREE', 'FROM',
	'FULL', 'FUNCTION', 'FUSION', 'GET', 'GLOBAL', 'GRANT', 'GROUP', 'GROUPING', 'HAVING',
	'HOLD', 'HOUR', 'IDENTITY', 'IN', 'INDICATOR', 'INNER', 'INOUT', 'INSENSITIVE', 'INSERT',
	'INT', 'INTEGER', 'INTERSECT', 'INTERSECTION', 'INTERVAL', 'INTO', 'IS', 'JOIN', 'LAG',
	'LANGUAGE', 'LARGE', 'LAST_VALUE', 'LATERAL', 'LEAD', 'LEADING', 'LEFT', 'LIKE',
	'LIKE_REGEX', 'LN', 'LOCAL', 'LOCALTIME', 'LOCALTIMESTAMP', 'LOWER', 'MATCH', 'MAX',
	'MAX_CARDINALITY', 'MEMBER', 'MERGE', 'METHOD', 'MIN', 'MINUTE', 'MOD', 'MODIFIES',
	'MODULE', 'MONTH', 'MULTISET', 'NATIONAL', 'NATURAL', 'NCHAR', 'NCLOB', 'NEW', 'NO',
	'NONE', 'NORMALIZE', 'NOT', 'NTH_VALUE', 'NTILE', 'NULL', 'NULLIF', 'NUMERIC',
	'OCTET_LENGTH', 'OCCURRENCES_REGEX', 'OF', 'OFFSET', 'OLD', 'ON', 'ONLY', 'OPEN',
	'OR', 'ORDER', 'OUT', 'OUTER', 'OVER', 'OVERLAPS', 'OVERLAY', 'PARAMETER', 'PARTITION',
	'PERCENT_RANK', 'PERCENTILE_CONT', 'PERCENTILE_DISC', 'POSITION', 'POSITION_REGEX',
	'POWER', 'PRECISION', 'PREPARE', 'PRIMARY', 'PROCEDURE', 'RANGE', 'RANK', 'READS',
	'REAL', 'RECURSIVE', 'REF', 'REFERENCES', 'REFERENCING', 'REGR_AVGX', 'REGR_AVGY',
	'REGR_COUNT', 'REGR_INTERCEPT', 'REGR_R2', 'REGR_SLOPE', 'REGR_SXX', 'REGR_SXY',
	'REGR_SYY', 'RELEASE', 'RESULT', 'RETURN', 'RETURNS', 'REVOKE', 'RIGHT', 'ROLLBACK',
	'ROLLUP', 'ROW', 'ROW_NUMBER', 'ROWS', 'SAVEPOINT', 'SCOPE', 'SCROLL', 'SEARCH',
	'SECOND', 'SELECT', 'SENSITIVE', 'SESSION_USER', 'SET', 'SIMILAR', 'SMALLINT',
	'SOME', 'SPECIFIC', 'SPECIFICTYPE', 'SQL', 'SQLEXCEPTION', 'SQLSTATE', 'SQLWARNING',
	'SQRT', 'START', 'STATIC', 'STDDEV_POP', 'STDDEV_SAMP', 'SUBMULTISET', 'SUBSTRING',
	'SUBSTRING_REGEX', 'SUM', 'SYMMETRIC', 'SYSTEM', 'SYSTEM_USER', 'TABLE', 'TABLESAMPLE',
	'THEN', 'TIME', 'TIMESTAMP', 'TIMEZONE_HOUR', 'TIMEZONE_MINUTE', 'TO', 'TRAILING',
	'TRANSLATE', 'TRANSLATE_REGEX', 'TRANSLATION', 'TREAT', 'TRIGGER', 'TRUNCATE',
	'TRIM', 'TRIM_ARRAY', 'TRUE', 'UESCAPE', 'UNION', 'UNIQUE', 'UNKNOWN', 'UNNEST',
	'UPDATE', 'UPPER', 'USER', 'USING', 'VALUE', 'VALUES', 'VAR_POP', 'VAR_SAMP',
	'VARBINARY', 'VARCHAR', 'VARYING', 'WHEN', 'WHENEVER', 'WHERE', 'WIDTH_BUCKET',
	'WINDOW', 'WITH', 'WITHIN', 'WITHOUT', 'YEAR',
}

--source: http://www.firebirdsql.org/rlsnotesh/rlsnotes25.html#rnfb25-reswords
--but doesn't say what they mean by "SQL Standard", so we don't know which is
--the keyword list we're basing the modifications on. We're assuming SQL-2008 Draft.
keywords['Firebird 2.5'] = remove(index{
	--added as non-reserved
	'AUTONOMOUS', 'BIN_NOT', 'CALLER', 'CHAR_TO_UUID', 'COMMON', 'DATA',
	'FIRSTNAME', 'GRANTED', 'LASTNAME', 'MIDDLENAME', 'MAPPING', 'OS_NAME',
	'SOURCE', 'TWO_PHASE', 'UUID_TO_CHAR',
}, copy(keywords['SQL-2008 Draft'], index{
	--reserved over the SQL standard
	'ADD', 'DB_KEY', 'GDSCODE', 'INDEX', 'LONG', 'PLAN', 'POST_EVENT',
	'RETURNING_VALUES', 'SQLCODE', 'VARIABLE', 'VIEW', 'WEEK', 'WHILE',
	--added as reserved
	'SIMILAR',
}))

keywords['All'] = {}
for _,list in pairs(keywords) do
	for k in pairs(list) do
		keywords['All'][k] = true
	end
end

return keywords

