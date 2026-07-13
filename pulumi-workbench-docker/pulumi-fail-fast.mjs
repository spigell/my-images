import fs from 'node:fs';
import { inspect } from 'node:util';

const USER_ACTIONABLE_MESSAGE_EXIT_CODE = 32;
let terminating = false;

const failFast = (origin, reason) => {
  if (terminating) {
    process.exit(USER_ACTIONABLE_MESSAGE_EXIT_CODE);
  }
  terminating = true;

  const details =
    reason instanceof Error
      ? reason.stack || `${reason.name}: ${reason.message}`
      : inspect(reason, {
          depth: 4,
          maxArrayLength: 20,
          maxStringLength: 2_000,
        });

  fs.writeSync(
    2,
    `Pulumi program terminated after an ${origin}:\n${details}\n`,
  );
  process.exit(USER_ACTIONABLE_MESSAGE_EXIT_CODE);
};

process.prependListener('uncaughtException', (error) =>
  failFast('uncaught exception', error),
);
process.prependListener('unhandledRejection', (reason) =>
  failFast('unhandled rejection', reason),
);
