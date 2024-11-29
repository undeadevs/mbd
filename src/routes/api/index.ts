import { Hono } from "hono";
import { authRouter } from "@/routes/api/auth";
import { monstersRouter } from "./monsters";
import { skillsRouter } from "./skills";
import { meRouter } from "./me";
import { playersRouter } from "./players";
import { battlesRouter } from "./battles";

const router = new Hono();

router.route("/auth", authRouter);
router.route("/me", meRouter);
router.route("/monsters", monstersRouter);
router.route("/skills", skillsRouter);
router.route("/players", playersRouter);
router.route("/battles", battlesRouter);

export { router as apiRouter };
