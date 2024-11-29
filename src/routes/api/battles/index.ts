import { Hono } from "hono";
import { battleRequestsRouter } from "./requests";

const router = new Hono();

router.route("/requests", battleRequestsRouter);

export { router as battlesRouter };
