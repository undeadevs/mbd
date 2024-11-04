import mysql, { type ProcedureCallPacket } from "mysql2/promise";

export const db = mysql.createPool({
   host: Bun.env.MYSQL_HOST || "localhost",
   port: Number(Bun.env.MYSQL_PORT || "3306"),
   user: Bun.env.MYSQL_USERNAME || "mbd_user",
   password: Bun.env.MYSQL_PASSWORD || "mbdsmt5",
   database: Bun.env.MYSQL_DBNAME || "mbd",
   waitForConnections: true,
   connectionLimit: 10,
   maxIdle: 10,
   idleTimeout: 60000,
   queueLimit: 0,
   enableKeepAlive: true,
   keepAliveInitialDelay: 0,
});

export async function callProc<T>(procName: string, ...procParams: unknown[]) {
   return db.query<ProcedureCallPacket<T>>(
      `CALL ${procName}(${procParams.map((_) => "?").join(",")})`,
      procParams,
   );
}
