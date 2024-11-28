import mysql, {
   type ProcedureCallPacket,
   type ResultSetHeader,
   type RowDataPacket,
} from "mysql2/promise";

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

export async function callProc<TResult extends (unknown | RowDataPacket)[]>(
   procName: string,
   ...procParams: unknown[]
) {
   const [procRes] = await db.query<ProcedureCallPacket>(
      `CALL ${procName}(${procParams.map((_) => "?").join(",")})`,
      procParams,
   );

   type TypedResult<TTypes> = TTypes extends [infer TFirst, ...infer TRest]
      ? [TFirst[], ...TypedResult<TRest>]
      : TTypes extends [infer TFirst]
        ? [TFirst[]]
        : TTypes extends []
          ? []
          : never;

   const res = {
      results: [] as TypedResult<TResult>,
      resultHeader: null as ResultSetHeader | null,
   };
   console.log(procRes);
   if (!Array.isArray(procRes)) {
      res.resultHeader = procRes;
      return res;
   }

   res.results = procRes.slice(0, procRes.length - 1) as TypedResult<TResult>;
   res.resultHeader = procRes[procRes.length - 1] as ResultSetHeader;

   return res;
}
