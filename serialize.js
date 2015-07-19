module.exports = serialize;

function serialize (node) {
  if (typeof node === 'string') {
    // the only place this happens is when referencing another rule
    return cleanRulename(node) + ': ' + cleanRulename(node)
  }
  return serializers[node.type](node);
}

function propSerializer (name, separator) {
  return function (node) {
    return [].concat(node[name]).map(serialize).join(separator);
  };
}

var serializers = {};

serializers.rulelist = propSerializer('rules', '\n');

serializers.rule = function rule (node) {
  if (node.defined_as !== '=') {
    throw new Error('defined_as must be =');
  }

  var prefix = cleanRulename(node.rulename) + '\n\t' + node.defined_as + ' ';
  return prefix + propSerializer('elements', '\n\t/ ')(node.elements) + '\n';
};

function cleanRulename (rulename) {
  return rulename.replace(/-/g, '_');
}

serializers.alternation = propSerializer('elements', ' / ');

serializers.concatenation = propSerializer('elements', ' ');

serializers.repetition = function repetition (node) {
  if (!node.repeat) {
    return serialize(node.element);
  }

  var least = parseIntFallback(node.repeat.least);
  var most = parseIntFallback(node.repeat.most);
  var specific = parseIntFallback(node.repeat.specific);

  if (specific > -1) {
    least = most = specific;
  }

  var diff = most - least;

  var result = serialize({
    type: 'concatenation',
    elements: filledArray(least, node.element)
  });

  if (isFinite(diff)) {
    result += ' ' + serialize({
      "type": "concatenation",
      "elements": filledArray(diff, {
        "type": "option",
        "element": node.element
      })
    });
  }
  else if (least > 0) {
    result += '+';
  }
  else {
    result += serialize(node.element) + '*';
  }

  return result;
};

function parseIntFallback(text, fallback) {
  var val = parseInt(text, 10);
  if (Number.isNaN(val)) {
    val = fallback;
  }
  return val;
}

function filledArray (length, value) {
  var result = [];
  while (length-- > 0) {
    result.push(value);
  }
  return result;
}

serializers.group = function group (node) {
  return '(' + serialize(node.element) + ')';
}

serializers.option = function option (node) {
  return serializers.group(node) + '?';
}

serializers.char_val = function char_val (node) {
  return JSON.stringify(node.value) + 'i';
}

serializers.num_val = propSerializer('value');

serializers.hex_val = function hex_val (node) {
  var value = node.value;
  if (value.type === 'series') {
    return '"\\x' + value.values.join('\\x') + '"';
  }
  else if (value.type === 'range') {
    return '[\\x' + value.min + '-\\x' + value.max + ']';
  }
  else {
    throw new Error('bad hex_val');
  }
};
