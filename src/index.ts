import { Hono, type Context } from "hono";
import { apiRouter } from "./routes/api";
import { HTTPException } from "hono/http-exception";

const app = new Hono();

app.onError((err, c: Context) => {
   if (err instanceof HTTPException) {
      return c.json({ error: err.message }, err.status);
   }

   if (err instanceof Error) {
      if ("sqlState" in err && err.sqlState === "45000") {
         return c.json({ error: err.message }, 400);
      }
   }

   console.error(err);

   return c.json({ error: "Internal server error" }, 503);
});

app.route("/api", apiRouter);

export default {
   port: 5321,
   fetch: app.fetch,
};
