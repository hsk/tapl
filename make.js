var fs = require('fs');
var execSync = require('child_process').execSync;

var srcs = [
        "arith",
        "untyped",
        "fulluntyped",
        "tyarith",

        "fullsimple",
        "simplebool",

        "fullref",
        "fullerror",
        "rcdsubbot",
        "fullsub",

        "bot",

        "fullequirec",
        "fullisorec",
        "equirec",

        "reconbase",
        "recon",
        "fullrecon",
        "fullpoly",
        "fullomega",

        "fullfomsub",
        "purefsub",
        "fullfsub",

        "fullfomsubref",

        "fomega",

        "fomsub",
        "fullfsubref",
        "fullupdate"
//        "joinexercise",
//        "letexercise",
];

for (var i = 0; i < srcs.length; i++) {
  var src = srcs[i];
  var text = fs.readFileSync(src+"/test.f", 'utf-8');
  console.log("## "+src+"\n");
  text = text.replace(/^/mg, "    ");
  console.log(text);
  console.log("<center>"+src+"/test.f</center>\n");

  console.log("### output");
  console.log("");


  var text = "" + execSync("./" + src + "/f ./"+src+"/test.f");
  text = text.replace(/^/mg, "    ");
  console.log(text);

}
