import { Hono } from "hono";
import { authRouter } from "@/routes/api/auth";
import { monsterRouter } from "./monsters";

const router = new Hono();

router.route("/auth", authRouter);
router.route("/monsters", monsterRouter);

export { router as apiRouter };
