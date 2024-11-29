import { Hono } from "hono";
import { battleRequestsRouter } from "./requests";
import { randomEncounterRouter } from "./random-encounter";
import { singleBattleRouter } from "./[id]";

const router = new Hono();

router.route("/requests", battleRequestsRouter);
router.route("/random-encounter", randomEncounterRouter);
router.route("/:id", singleBattleRouter);

export { router as battlesRouter };
