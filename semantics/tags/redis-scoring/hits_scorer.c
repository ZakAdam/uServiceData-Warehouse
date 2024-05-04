#include <redisearch.h>
#include <string.h>
#include <stdio.h>
#include "hits_scorer.h"

double HitsScorer(const ScoringFunctionArgs *ctx, const RSIndexResult *r, const RSDocumentMetadata *dmd,
                   double minScore) {
  // no need to evaluate documents with score 0
  if (dmd->score == 0) return 0;

  // Get the query string from the context
  const char *queryString = ctx->qdata;

  // Initialize a variable to count the matches
  int matchCount = 0;

  // Loop through each term in the result
  for (int i = 0; i < r->agg.numChildren; i++) {
    const char *term = r->agg.children[i]->term.term->str;

    // Debug print used for displaying terms
    // printf("Term %d: %s\n", i, term);

    // Check if the term exists in the query string
    if (strstr(queryString, term) != NULL) {
	  // Increment match count if the term is found in the query
      matchCount++;
    }
  }

  // Return the match count as the score
  //return (double)matchCount;
  return matchCount;
}

int RS_ExtensionInit(RSExtensionCtx *ctx) {

  if (ctx->RegisterScoringFunction(SCORER_NAME, HitsScorer, NULL, NULL) == REDISEARCH_ERR) {
    return REDISEARCH_ERR;
  }

  return REDISEARCH_OK;
}
