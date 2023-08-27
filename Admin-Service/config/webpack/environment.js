const { environment } = require('@rails/webpacker')

module.exports = environment

// Needed to compile assets:precompile on older Ruby version
const crypto = require("crypto");
const crypto_orig_createHash = crypto.createHash;
crypto.createHash = algorithm => crypto_orig_createHash(algorithm == "md4" ? "sha256" : algorithm);
