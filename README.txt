# **Concise Installation Guide**

## **Step-by-Step Setup**

1. **Open the MIT App Inventor project** and download the Android app to your phone
2. **Install AutoHotKey v1.1.37.02** using the setup executable
3. **Install the CP210x Universal Windows Driver** (Right-click `silabser.inf` and select "Install" - follow the instructions)
4. **Open Arduino IDE** and copy the code from the provided Arduino file
5. **Connect your ESP32** (we use a DEVKIT V1) to your PC
6. **Install the ESP32 board package and BluetoothSerial library** in Arduino IDE
7. **Configure board settings:**
   - **Board:** Select your ESP32 board
   - **Upload Speed:** 115200
   - **Flash Frequency:** 80MHz
   - **Port:** Select the available COM port (appears after driver installation)
8. **Verify and upload** the code to your ESP32
9. **Close Arduino IDE** (otherwise commands will execute in the serial monitor)
10. **Open `PPT_Funcional.ahk`**, select your COM port, and click Connect
11. **Open the app on your phone**, search for devices, and connect to "ControlPPT"
12. **Open your PowerPoint presentation** and start presenting

---

## **Customization & Notes**

Feel free to adjust everything to your needs. The design is modular—simply modify the app and script to add or remove buttons according to your requirements.