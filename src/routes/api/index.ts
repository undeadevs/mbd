import { Hono } from "hono";
import { authRouter } from "@/routes/api/auth";
import { monstersRouter } from "./monsters";
import { skillsRouter } from "./skills";

const router = new Hono();

router.route("/auth", authRouter);
router.route("/monsters", monstersRouter);
router.route("/skills", skillsRouter);

export { router as apiRouter };
