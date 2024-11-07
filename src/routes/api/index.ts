import { Hono } from "hono";
import { authRouter } from "@/routes/api/auth";
import { monstersRouter } from "./monsters";

const router = new Hono();

router.route("/auth", authRouter);
router.route("/monsters", monstersRouter);

export { router as apiRouter };
