import { Hono } from "hono";
import { battleRequestsRouter } from "./requests";
import { randomEncounterRouter } from "./random-encounter";

const router = new Hono();

router.route("/requests", battleRequestsRouter);
router.route("/random-encounter", randomEncounterRouter);

export { router as battlesRouter };
