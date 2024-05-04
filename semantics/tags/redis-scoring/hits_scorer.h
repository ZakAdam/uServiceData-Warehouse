#ifndef __EXT_HITS_SCORER_H__
#define __EXT_HITS_SCORER_H__
#include "redisearch.h"

#define SCORER_NAME "HITS_SCORER"

int RS_ExtensionInit(RSExtensionCtx *ctx);

#endif
