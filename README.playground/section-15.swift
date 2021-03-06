func crypt(sc : StreamCryptor,  inputStream: NSInputStream, outputStream: NSOutputStream, bufferSize: Int)
{
    var inputBuffer = Array<UInt8>(count:1024, repeatedValue:0)
    var outputBuffer = Array<UInt8>(count:1024, repeatedValue:0)
    inputStream.open()
    outputStream.open()

    var cryptedBytes : Int = 0    
    while inputStream.hasBytesAvailable
    {
        let bytesRead = inputStream.read(&inputBuffer, maxLength: inputBuffer.count)
        let status = sc.update(inputBuffer, byteCountIn: bytesRead, bufferOut: &outputBuffer, byteCapacityOut: outputBuffer.count, byteCountOut: &cryptedBytes)
        assert(status == Status.Success)
        if(cryptedBytes > 0)
        {
            let bytesWritten = outputStream.write(outputBuffer, maxLength: Int(cryptedBytes))
            assert(bytesWritten == Int(cryptedBytes))
        }
    }
    let status = sc.final(&outputBuffer, byteCapacityOut: outputBuffer.count, byteCountOut: &cryptedBytes)    
    assert(status == Status.Success)
    if(cryptedBytes > 0)
    {
        let bytesWritten = outputStream.write(outputBuffer, maxLength: Int(cryptedBytes))
        assert(bytesWritten == Int(cryptedBytes))
    }
    inputStream.close()
    outputStream.close()
}

let imagePath = NSBundle.mainBundle().pathForResource("Riscal", ofType:"jpg")!
let tmp = NSTemporaryDirectory() as NSString
let encryptedFilePath = tmp.stringByAppendingPathComponent("Riscal.xjpgx")
var decryptedFilePath = tmp.stringByAppendingPathComponent("RiscalDecrypted.jpg")

var imageInputStream = NSInputStream(fileAtPath: imagePath)
var encryptedFileOutputStream = NSOutputStream(toFileAtPath: encryptedFilePath, append:false)
var encryptedFileInputStream = NSInputStream(fileAtPath: encryptedFilePath)
var decryptedFileOutputStream = NSOutputStream(toFileAtPath: decryptedFilePath, append:false)

var sc = StreamCryptor(operation:.Encrypt, algorithm:.AES, options:.PKCS7Padding, key:key, iv:Array<UInt8>())
crypt(sc, inputStream: imageInputStream!, outputStream: encryptedFileOutputStream!, bufferSize: 1024)

// Uncomment this line to verify that the file is encrypted
//var encryptedImage = UIImage(contentsOfFile:encryptedFile)

sc = StreamCryptor(operation:.Decrypt, algorithm:.AES, options:.PKCS7Padding, key:key, iv:Array<UInt8>())
crypt(sc, inputStream: encryptedFileInputStream!, outputStream: decryptedFileOutputStream!, bufferSize: 1024)

var image = NSImage(named:"Riscal.jpg")
var decryptedImage = NSImage(contentsOfFile:decryptedFilePath)
