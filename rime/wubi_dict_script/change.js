const fs = require("fs");

// 创建一个可读流，读取 input.txt 文件
const readStream = fs.createReadStream("input.txt", { encoding: "utf8" });

// 创建一个可写流，写入 output.txt 文件
const writeStream = fs.createWriteStream("output.txt", { encoding: "utf8" });

// 每次读取一行，处理后写入写入流中
readStream.on("data", (chunk) => {
  // 将读取到的一整行分割为数组
  const lines = chunk.split("\n");
  lines.forEach((line) => {
    const processedLine = line.trim();

    let myArray = processedLine.split("\t");
    [myArray[0], myArray[1]] = [myArray[1], myArray[0]];
    let result = myArray.join("\t");

    writeStream.write(`${result}\n`);
  });
});

// 当读取结束时，关闭可写流
readStream.on("end", () => {
  writeStream.end();
});
