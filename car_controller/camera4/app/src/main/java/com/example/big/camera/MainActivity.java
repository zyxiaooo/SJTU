package com.example.big.camera;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.util.List;
import java.util.UUID;

public class MainActivity extends AppCompatActivity implements SurfaceHolder.Callback {
    public Camera camera;
    public int i=0;
    public CharSequence myip;
    public static TextView ipview;
    public static Button Connect;
    public SurfaceView mpreview;
    public SurfaceHolder mSurfaceHolder;
    public Socket socket= null;
    public Thread mReceiveThread;
    public boolean fff=true;
    public boolean start=false;
    public Handler myHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (msg.what == 0x11) {
                Bundle bundle = msg.getData();

            }
        }

    };
    private BluetoothSocket carsocket;
    private static UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ipview = (EditText) findViewById(R.id.editText);
        Connect = (Button) findViewById(R.id.button);
        Connect.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                start=true;
                myip=ipview.getText();
            }
        });

        if (adapter != null) {

            if (!adapter.isEnabled()) {

                Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                startActivity(enableBtIntent);

            }
        }

        for (BluetoothDevice device : adapter.getBondedDevices()) {Log.i("tag",""+device.getName());
            if (device.getName().equals("HC-06"))
            {

                try {
                    if (carsocket != null)
                        carsocket.close();

                    carsocket = device.createRfcommSocketToServiceRecord(uuid);

                    adapter.cancelDiscovery();
                    carsocket.connect();



                } catch (IOException e) {
                    e.printStackTrace();
                }

            }
        }

        if (carsocket == null) {
            //text_setText(" 连接失败");

            return;
        }

        mpreview = (SurfaceView) this.findViewById(R.id.surfaceView);

        mSurfaceHolder = mpreview.getHolder();

        mSurfaceHolder.addCallback(this);

        mSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    }
    @Override
    public void surfaceCreated(SurfaceHolder holder)
        {
           camera = Camera.open(0);
            camera.setDisplayOrientation(90);
            camera.setPreviewCallback(mJpegPreviewCallback);
            Camera.Parameters parameters = camera.getParameters();
            // 设置预览照片的大小
            parameters.setPreviewSize(1200, 800);
            // 设置预览照片时每秒显示多少帧的最小值和最大值
            parameters.setPreviewFpsRange(7, 7);
            // 设置图片格式
            parameters.setPictureFormat(ImageFormat.JPEG);
            // 设置JPG照片的质量
            parameters.set("jpeg-quality", 1);
            // 设置照片的大小
            parameters.setPictureSize(1200, 800);
            // 通过SurfaceView显示取景画面
        }
    public void surfaceChanged(SurfaceHolder holder, int format, int w, int h)

    {
       Camera.Parameters parameters = camera.getParameters();
      parameters.setPreviewSize(w, h);

        try {
            camera.setPreviewDisplay(holder);

        } catch (IOException exception) {

            camera.release();

            camera = null;

        }

        camera.startPreview();

    }


    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        camera.setPreviewCallback(null);
       camera.release();
    }

    Camera.PreviewCallback mJpegPreviewCallback = new Camera.PreviewCallback()
    {
        @Override
        public void onPreviewFrame(byte[] data, Camera camera) {
            if (start == true) {
                try {
                    Camera.Size size = camera.getParameters().getPreviewSize();
                    Log.i("tag",myip.toString());
                    ++i;
                    if (i == 1) {
                        i = 0;
                        try {
                            // 调用image.compressToJpeg（）将YUV格式图像数据data转为jpg格式
                            YuvImage image = new YuvImage(data, ImageFormat.NV21, size.width,
                                    size.height, null);
                            if (image != null) {
                                ByteArrayOutputStream outstream = new ByteArrayOutputStream();
                                image.compressToJpeg(new Rect(0, 0, size.width/2, size.height/2),
                                        8, outstream);
                                outstream.flush();
                                // 启用线程将图像数据发送出去
                                Thread th = new MyThread3(outstream);
                                if (fff == true) {
                                    th.start();
                                    fff = false;
                                }

                            }
                        } catch (Exception ex) {
                            Log.e("Sys", "Error:" + ex.getMessage());
                        }
                    }

                } catch (Exception e) {
                    Log.v("System.out", e.toString());
                }


            }
        }
    };
    class MyThread3 extends Thread {
        private byte byteBuffer[] = new byte[1024];
        private byte byteBuffer1[] = new byte[1];
        private InputStream insocket;
        private OutputStream outsocket;
        private ByteArrayOutputStream myoutputstream;
        private String ipname;

        public MyThread3(ByteArrayOutputStream myoutputstream) {
            this.myoutputstream = myoutputstream;

            try {
                myoutputstream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        public void run() {
            try {
                // 将图像数据通过Socket发送出去
                socket = new Socket(myip.toString(),30000);
              // mReceiveThread = new ReceiveThread(socket);
               // mReceiveThread.start();

                BufferedReader bff = new BufferedReader(new InputStreamReader(
                        socket.getInputStream()));
                outsocket = socket.getOutputStream();
                Log.i("tag","nidaye");
                String line = null;
                String buffer="";
                while ((line = bff.readLine()) != null) {
                    buffer = line + buffer;
                }

                Log.i("tag",buffer);
                if(!buffer.equals("9"))
                try {
                    carsocket.getOutputStream().write(buffer.getBytes());
                    carsocket.getOutputStream().flush();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                ByteArrayInputStream inputstream = new ByteArrayInputStream(
                        myoutputstream.toByteArray());
                int amount;
                while ((amount = inputstream.read(byteBuffer)) != -1) {
                    outsocket.write(byteBuffer, 0, amount);
                }
                myoutputstream.flush();
                myoutputstream.close();
                fff=true;

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    private class ReceiveThread extends Thread
    {
        private InputStream inStream = null;
        private byte[] buf;
        private String str = null;
        ReceiveThread(Socket s)
        {
            try {
                //获得输入流
                this.inStream = s.getInputStream();

            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        @Override
        public void run()
        {
                this.buf = new byte[1];

                try {
                    //读取输入数据（阻塞）
                    this.inStream.read(this.buf);
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }

                //字符编码转换
                try {
                    this.str = new String(this.buf, "GB2312").trim();
                    Log.i("tag","dui le wo jiu da you xi");
                } catch (UnsupportedEncodingException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }




        }


    }


    }
