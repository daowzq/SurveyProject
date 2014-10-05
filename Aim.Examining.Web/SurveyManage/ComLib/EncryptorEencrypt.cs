using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace WebSecurity
{
    public class EncryptorEencrypt
    {
        #region CBC模式**


        /// <summary>

        /// DES3 CBC模式加密

        /// </summary>

        /// <param name="key">密钥</param>

        /// <param name="iv">IV</param>

        /// <param name="data">明文的byte数组</param>

        /// <returns>密文的byte数组</returns>

        public static byte[] Des3EncodeCBC(byte[] key, byte[] iv, byte[] data)
        {

            //复制于MSDN


            try
            {

                // Create a MemoryStream.

                MemoryStream mStream = new MemoryStream();


                TripleDESCryptoServiceProvider tdsp = new TripleDESCryptoServiceProvider();

                tdsp.Mode = CipherMode.CBC;             //默认值

                tdsp.Padding = PaddingMode.PKCS7;       //默认值


                // Create a CryptoStream using the MemoryStream 
                // and the passed key and initialization vector (IV).

                CryptoStream cStream = new CryptoStream(mStream,

                    tdsp.CreateEncryptor(key, iv),

                    CryptoStreamMode.Write);


                // Write the byte array to the crypto stream and flush it.

                cStream.Write(data, 0, data.Length);

                cStream.FlushFinalBlock();


                // Get an array of bytes from the 
                // MemoryStream that holds the 
                // encrypted data.

                byte[] ret = mStream.ToArray();


                // Close the streams.

                cStream.Close();

                mStream.Close();


                // Return the encrypted buffer.

                return ret;

            }

            catch (CryptographicException e)
            {

                Console.WriteLine("A Cryptographic error occurred: {0}", e.Message);

                return null;

            }

        }


        /// <summary>

        /// DES3 CBC模式解密

        /// </summary>

        /// <param name="key">密钥</param>

        /// <param name="iv">IV</param>

        /// <param name="data">密文的byte数组</param>

        /// <returns>明文的byte数组</returns>

        public static byte[] Des3DecodeCBC(byte[] key, byte[] iv, byte[] data)
        {

            try
            {

                // Create a new MemoryStream using the passed 
                // array of encrypted data.

                MemoryStream msDecrypt = new MemoryStream(data);


                TripleDESCryptoServiceProvider tdsp = new TripleDESCryptoServiceProvider();

                tdsp.Mode = CipherMode.CBC;

                tdsp.Padding = PaddingMode.PKCS7;


                // Create a CryptoStream using the MemoryStream 
                // and the passed key and initialization vector (IV).

                CryptoStream csDecrypt = new CryptoStream(msDecrypt,

                    tdsp.CreateDecryptor(key, iv),

                    CryptoStreamMode.Read);


                // Create buffer to hold the decrypted data.

                byte[] fromEncrypt = new byte[data.Length];


                // Read the decrypted data out of the crypto stream

                // and place it into the temporary buffer.

                csDecrypt.Read(fromEncrypt, 0, fromEncrypt.Length);


                //Convert the buffer into a string and return it.

                return fromEncrypt;

            }

            catch (CryptographicException e)
            {

                Console.WriteLine("A Cryptographic error occurred: {0}", e.Message);

                return null;

            }

        }


        #endregion


        #region ECB模式


        /// <summary>

        /// DES3 ECB模式加密

        /// </summary>

        /// <param name="key">密钥</param>

        /// <param name="iv">IV(当模式为ECB时，IV无用)</param>

        /// <param name="str">明文的byte数组</param>

        /// <returns>密文的byte数组</returns>

        public static byte[] Des3EncodeECB(byte[] key, byte[] iv, byte[] data)
        {

            try
            {

                // Create a MemoryStream.

                MemoryStream mStream = new MemoryStream();


                TripleDESCryptoServiceProvider tdsp = new TripleDESCryptoServiceProvider();

                tdsp.Mode = CipherMode.ECB;

                tdsp.Padding = PaddingMode.PKCS7;

                // Create a CryptoStream using the MemoryStream 
                // and the passed key and initialization vector (IV).

                CryptoStream cStream = new CryptoStream(mStream,

                    tdsp.CreateEncryptor(key, iv),

                    CryptoStreamMode.Write);


                // Write the byte array to the crypto stream and flush it.

                cStream.Write(data, 0, data.Length);

                cStream.FlushFinalBlock();


                // Get an array of bytes from the 
                // MemoryStream that holds the 
                // encrypted data.

                byte[] ret = mStream.ToArray();


                // Close the streams.

                cStream.Close();

                mStream.Close();


                // Return the encrypted buffer.

                return ret;

            }

            catch (CryptographicException e)
            {

                Console.WriteLine("A Cryptographic error occurred: {0}", e.Message);

                return null;

            }


        }


        /// <summary>

        /// DES3 ECB模式解密

        /// </summary>

        /// <param name="key">密钥</param>

        /// <param name="iv">IV(当模式为ECB时，IV无用)</param>

        /// <param name="str">密文的byte数组</param>

        /// <returns>明文的byte数组</returns>

        public static byte[] Des3DecodeECB(byte[] key, byte[] iv, byte[] data)
        {

            try
            {

                // Create a new MemoryStream using the passed 
                // array of encrypted data.

                MemoryStream msDecrypt = new MemoryStream(data);


                TripleDESCryptoServiceProvider tdsp = new TripleDESCryptoServiceProvider();

                tdsp.Mode = CipherMode.ECB;

                tdsp.Padding = PaddingMode.PKCS7;


                // Create a CryptoStream using the MemoryStream 
                // and the passed key and initialization vector (IV).

                CryptoStream csDecrypt = new CryptoStream(msDecrypt,

                    tdsp.CreateDecryptor(key, iv),

                    CryptoStreamMode.Read);


                // Create buffer to hold the decrypted data.

                byte[] fromEncrypt = new byte[data.Length];


                // Read the decrypted data out of the crypto stream

                // and place it into the temporary buffer.

                csDecrypt.Read(fromEncrypt, 0, fromEncrypt.Length);


                //Convert the buffer into a string and return it.

                return fromEncrypt;

            }

            catch (CryptographicException e)
            {

                Console.WriteLine("A Cryptographic error occurred: {0}", e.Message);

                return null;

            }

        }
        #endregion


        /// <summary>
        /// md5加密(UTF8)
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static String MD5Encrypt(String s)
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] bytes = System.Text.Encoding.UTF8.GetBytes(s);
            bytes = md5.ComputeHash(bytes);
            md5.Clear();

            StringBuilder strb = new StringBuilder();
            for (int i = 0; i < bytes.Length; i++)
            {
                strb.Append(Convert.ToString(bytes[i], 16).PadLeft(2, '0'));
            }
            return strb.ToString().PadLeft(32, '0');
        }

        /// <summary>
        /// md5加密(UTF8)
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static String MD5Encrypt1(String s)
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] bytes = System.Text.Encoding.UTF8.GetBytes(s);
            bytes = md5.ComputeHash(bytes);
            md5.Clear();

            StringBuilder strb = new StringBuilder();
            for (int i = 0; i < bytes.Length; i++)
            {
                strb.Append(Convert.ToString(bytes[i], 16).PadLeft(2, '0'));
            }
            return strb.ToString().PadLeft(32, '0');
        }

        /// <summary>
        /// 给一个字符串加密
        /// </summary>
        /// <param name="strText"></param>
        /// <returns></returns>
        public static string MD5EncryptOrg(string strText)
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] result = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(strText));
            return System.Text.Encoding.UTF8.GetString(result);
        }

        /// <summary>
        /// 加密
        /// </summary>
        /// <param name="json"></param>
        /// <returns></returns>
        public static string Des3EncrypStr(string json)
        {
            string base64 = Convert.ToBase64String(System.Text.Encoding.Default.GetBytes(json));
            byte[] bt = Convert.FromBase64String(base64);

            byte[] key = Convert.FromBase64String("jLj7893JLKpifjklUJpoj8093jkJLjp4");
            byte[] iv = new byte[] { 1, 2, 3, 4, 5, 6, 7, 8 };

            byte[] str = EncryptorEencrypt.Des3EncodeECB(key, iv, bt);
            return Convert.ToBase64String(str);
            //  return json;
        }

        /// <summary>
        /// 加密
        /// </summary>
        /// <param name="json"></param>
        /// <returns></returns>
        public static string Des3EncrypStrForHtml(string json)
        {
            string base64 = Convert.ToBase64String(System.Text.Encoding.Default.GetBytes(json));

            byte[] bt = Convert.FromBase64String(base64);

            byte[] key = Convert.FromBase64String("jLj7893JLKpifjklUJpoj8093jkJLjp4");
            byte[] iv = new byte[] { 1, 2, 3, 4, 5, 6, 7, 8 };

            byte[] str = EncryptorEencrypt.Des3EncodeECB(key, iv, bt);
            return Convert.ToBase64String(str).Replace("+", "%2B");   //处理网页传参"+" 变空格 ;
            //  return json;
        }

        /// <summary>
        /// 解密
        /// </summary>
        /// <param name="json"></param>
        /// <returns></returns>
        public static string Des3DecryptStr(string json)
        {
            //string base64 = Convert.ToBase64String(System.Text.Encoding.Default.GetBytes(json));
            //base64 = base64.Replace("+", "%2B");            //处理网页传参"+" 变空格 
            byte[] bt = Convert.FromBase64String(json);

            byte[] key = Convert.FromBase64String("jLj7893JLKpifjklUJpoj8093jkJLjp4");
            byte[] iv = new byte[] { };

            byte[] str = EncryptorEencrypt.Des3DecodeECB(key, null, bt);
            return Encoding.UTF8.GetString(str).Trim();
        }

    }
}