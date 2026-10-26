import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const MESSAGE_TYPE = "continue-after-compaction";

const buildContinuationPrompt = (): string => `Compaction is complete. Continue the existing task now.

Use the compacted context and the current repository state. Recover the goal, constraints, completed work, unresolved work, and intended next action. Do not inspect the raw session JSONL unless the compacted context is genuinely insufficient. Briefly state the context that you recovered, then immediately do the next unfinished step. Do not stop after the recap.`;

interface PendingContinuation {
	compactionEntryId: string;
	prompt: string;
	timer: ReturnType<typeof setTimeout> | undefined;
}

/**
 * Resume work after compaction, unless Pi will retry or a new user message
 * already gives the agent its next task.
 */
export default function continueAfterCompaction(pi: ExtensionAPI): void {
	let pending: PendingContinuation | undefined;

	const cancelPending = (): void => {
		if (pending?.timer !== undefined) {
			clearTimeout(pending.timer);
		}
		pending = undefined;
	};

	const continueIfIdle = (ctx: ExtensionContext): void => {
		if (pending === undefined || !ctx.isIdle() || ctx.hasPendingMessages()) {
			return;
		}

		const continuation = pending;
		pending = undefined;
		pi.sendMessage(
			{
				customType: MESSAGE_TYPE,
				content: continuation.prompt,
				display: false,
				details: { compactionEntryId: continuation.compactionEntryId },
			},
			{ triggerTurn: true },
		);
	};

	pi.on("session_compact", (event, ctx) => {
		cancelPending();

		// Overflow recovery already continues the interrupted turn.
		if (event.willRetry) {
			return;
		}

		const compactionEntryId = event.compactionEntry.id;
		const timer = setTimeout(() => {
			if (pending?.compactionEntryId !== compactionEntryId) {
				return;
			}
			pending.timer = undefined;
			continueIfIdle(ctx);
		}, 0);

		pending = {
			compactionEntryId,
			prompt: buildContinuationPrompt(),
			timer,
		};
	});

	// Auto-compaction settles after the session_compact event.
	pi.on("agent_settled", (_event, ctx) => {
		continueIfIdle(ctx);
	});

	// A real user message takes priority over an automatic continuation. The
	// message_start check also covers prompts that caused pre-prompt compaction.
	pi.on("input", () => {
		cancelPending();
	});
	pi.on("message_start", (event) => {
		if (event.message.role === "user") {
			cancelPending();
		}
	});

	pi.on("session_shutdown", () => {
		cancelPending();
	});
}
