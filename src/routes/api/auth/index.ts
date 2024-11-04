import { Hono } from "hono";
import { loginRouter } from "@/routes/api/auth/login";
import { registerRouter } from "@/routes/api/auth/register";
import { logoutRouter } from "@/routes/api/auth/logout";

const router = new Hono();

router.route("/login", loginRouter);
router.route("/register", registerRouter);
router.route("/logout", logoutRouter);

export { router as authRouter };
