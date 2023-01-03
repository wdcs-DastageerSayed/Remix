function namehash(name) {
  var _, label, remainder;

  if (name === "") {
    console.log("\u0000" * 32)
  } else {
    [label, _, remainder] = name.partition(".");
    return sha3(namehash(remainder) + sha3(label));
  }
}

