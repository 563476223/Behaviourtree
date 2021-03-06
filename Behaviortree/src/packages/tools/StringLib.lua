---------------------------
-- expend lua string lib --
---------------------------

local string = string
local bit    = bit
local Lib    = {}

-- Unicode 转 UTF8 编码
function string.unicode_2_utf8(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end
    local resultStr=""
    local i=1
    while true do
        local num1=string.byte(convertStr,i)
        local unicode
        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end
        -- print(unicode)
        if unicode <= 0x007f then
            resultStr=resultStr..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    resultStr=resultStr..'\0'
    return resultStr
end

-- UTF8 转 Unicode 编码
function string.utf8_to_unicode(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end
    local resultStr=""
    local i=1
    local num1=string.byte(convertStr,i)
    while num1~=nil do
        -- print(num1)
        local tempVar1,tempVar2
        if num1 >= 0x00 and num1 <= 0x7f then
            tempVar1=num1
            tempVar2=0
        elseif bit.band(num1,0xe0)== 0xc0 then
            local t1 = 0
            local t2 = 0
            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            t2 = bit.band(num1,bit.rshift(0xff,2))
            tempVar1=bit.bor(t2,bit.lshift(bit.band(t1,bit.rshift(0xff,6)),6))
            tempVar2=bit.rshift(t1,2)
        elseif bit.band(num1,0xf0)== 0xe0 then
            local t1 = 0
            local t2 = 0
            local t3 = 0
            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            t2 = bit.band(num1,bit.rshift(0xff,2))
            i=i+1
            num1=string.byte(convertStr,i)
            t3 = bit.band(num1,bit.rshift(0xff,2))
            tempVar1=bit.bor(bit.lshift(bit.band(t2,bit.rshift(0xff,6)),6),t3)
            tempVar2=bit.bor(bit.lshift(t1,4),bit.rshift(t2,2))
        
        end
        resultStr=resultStr..string.format("\\u%02x%02x",tempVar2,tempVar1)
        -- print(resultStr)
        i=i+1
        num1=string.byte(convertStr,i)
    end
    return resultStr
end

-- 查找最后一个字符串
function string.findLast(str,target)
    local i = str:match(".*"..target.."()")
    if i then return i-1 end
end

-- Base64编码
function string.base64_encode(text)
    local len = string.len(text)
    local left = len % 3
    len = len - left
    local res = {}
    local index = 1
    for i = 1, len, 3 do
        local a = string.byte(text, i )
        local b = string.byte(text, i + 1)
        local c = string.byte(text, i + 2)
        -- num = a<<16 + b<<8 + c
        local num = a * 65536 + b * 256 + c
        for j = 1, 4 do  
            --tmp = num >> ((4 -j) * 6)  
            local tmp = math.floor(num / (2 ^ ((4-j) * 6)))
            --curPos = tmp&0x3f
            local curPos = tmp % 64 + 1
            res[index] = Lib.__code[curPos]
            index = index + 1
        end
    end
    if left == 1 then
        Lib.__left1(res, index, text, len)
    elseif left == 2 then
        Lib.__left2(res, index, text, len)
    end
    return table.concat(res)
end

-- Base64解码
function string.base64_decode(text)
    local len = string.len(text)
    local left = 0
    if string.sub(text, len - 1) == "==" then
        left = 2
        len = len - 4
    elseif string.sub(text, len) == "=" then
        left = 1
        len = len - 4
    end
    local res = {}
    local index = 1
    local decode = Lib.__decode
    for i =1, len, 4 do
        local a = decode[string.byte(text,i    )]
        local b = decode[string.byte(text,i + 1)]
        local c = decode[string.byte(text,i + 2)]
        local d = decode[string.byte(text,i + 3)]
        --num = a<<18 + b<<12 + c<<6 + d
        local num = a * 262144 + b * 4096 + c * 64 + d
        local e = string.char(num % 256)
        num = math.floor(num / 256)
        local f = string.char(num % 256)
        num = math.floor(num / 256)
        res[index ] = string.char(num % 256)
        res[index + 1] = f
        res[index + 2] = e
        index = index + 3
    end
    if left == 1 then
        Lib.__decodeLeft1(res, index, text, len)
    elseif left == 2 then
        Lib.__decodeLeft2(res, index, text, len)
    end
    return table.concat(res)
end

-- 字节数据转16进制
function string.bin2hex(s, pre, tail)
    pre  = pre  or ""
    tail = tail or ""
    s=string.gsub(s,"(.)",function (x) return string.format(pre.."%02X"..tail,string.byte(x)) end)
    return s
end

function string.hex2bin(hexstr)
    hexstr = hexstr:gsub("0x",""):gsub("0X","")
    return tonumber(hexstr, 16) or -1
end

function string.md5_string(str)
    return MD5:String(str)
end

function string.md5_file(file)
    return MD5:File(file)
end

function string.aes_encrypt(text,password)
    return AES:create(password):Cipher(text)
end

function string.aes_decrypt(text,password)
    return AES:create(password):InvCipher(text)
end

Lib.__code = {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
            'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
            'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/',
        };  
Lib.__decode = {}
for k,v in pairs(Lib.__code) do
    Lib.__decode[string.byte(v,1)] = k - 1
end

function Lib.__left2(res, index, text, len)
    local num1 = string.byte(text, len + 1)
    num1 = num1 * 1024 --lshift 10
    local num2 = string.byte(text, len + 2)
    num2 = num2 * 4 --lshift 2
    local num = num1 + num2
    local tmp1 = math.floor(num / 4096) --rShift 12
    local curPos = tmp1 % 64 + 1
    res[index] = Lib.__code[curPos]
    local tmp2 = math.floor(num / 64)
    curPos = tmp2 % 64 + 1
    res[index + 1] = Lib.__code[curPos]
    curPos = num % 64 + 1
    res[index + 2] = Lib.__code[curPos]
    res[index + 3] = "="
end  
  
function Lib.__left1(res, index,text, len)
    local num = string.byte(text, len + 1)
    num = num * 16
    local tmp = math.floor(num / 64)
    local curPos = tmp % 64 + 1
    res[index ] = Lib.__code[curPos]
    curPos = num % 64 + 1
    res[index + 1] = Lib.__code[curPos]
    res[index + 2] = "="
    res[index + 3] = "="
end

function Lib.__decodeLeft1(res, index, text, len)
    local decode = Lib.__decode
    local a = decode[string.byte(text, len + 1)]
    local b = decode[string.byte(text, len + 2)]
    local c = decode[string.byte(text, len + 3)]
    local num = a * 4096 + b * 64 + c
    local num1 = math.floor(num / 1024) % 256
    local num2 = math.floor(num / 4) % 256
    res[index] = string.char(num1)
    res[index + 1] = string.char(num2)
end

function Lib.__decodeLeft2(res, index, text, len)
    local decode = Lib.__decode
    local a = decode[string.byte(text, len + 1)]
    local b = decode[string.byte(text, len + 2)]
    local num = a * 64 + b
    num = math.floor(num / 16)
    res[index] = string.char(num)
end