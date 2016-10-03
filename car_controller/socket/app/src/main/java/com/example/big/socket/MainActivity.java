package com.example.big.socket;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.graphics.ImageFormat;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.app.Activity;
import android.content.Context;
import android.view.SurfaceHolder;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.view.Menu;
import android.view.MenuItem;
import java.io.ByteArrayOutputStream;
import android.util.Log;
import android.view.MotionEvent;
import android.support.v4.view.GestureDetectorCompat;
import android.view.GestureDetector;

public class MainActivity extends Activity implements GestureDetector.OnGestureListener,
        GestureDetector.OnDoubleTapListener{

    public static ServerSocket serverSocket = null;
    public static TextView mTextView, textView1;
    public static ImageView iView;
    public static Uri imageUri;
    public  Socket socket=null;
    int flag=-1;
    SurfaceHolder surfaceHolder;
    public static ImageView im;
    static Bitmap bitmap;
    private OutputStream outStream = null;
    Button sendstop;
    Button sendup;
    Button senddown;
    Button sendleft;
    Button sendright;
    Button pressMode;
    Button gestureMode;
    Camera camera;
    private String IP = "";
    String buffer = "";
    boolean isPreview = false;

    private GestureDetectorCompat myGesture;
    public int methodState = 0;


    public static Handler mHandler = new Handler() {
        @Override
        public void handleMessage(android.os.Message msg) {

            im.setImageBitmap(bitmap);
        };
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mTextView = (TextView) findViewById(R.id.textsss);
        textView1 = (TextView) findViewById(R.id.textView1);

        this.myGesture = new GestureDetectorCompat(this,this);
        myGesture.setOnDoubleTapListener(this);

        IP = getlocalip();
       textView1.setText("IP addresss:"+IP);
        im=(ImageView)findViewById(R.id.imageView);
        sendstop = (Button) findViewById(R.id.buttonstop);
        sendup = (Button) findViewById(R.id.buttonup);
        senddown = (Button) findViewById(R.id.buttondown);
        sendleft = (Button) findViewById(R.id.buttonleft);
        sendright = (Button) findViewById(R.id.buttonright);
        pressMode = (Button) findViewById(R.id.buttonPress);
        gestureMode = (Button) findViewById(R.id.buttonGesture);
        sendstop.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if(methodState == 0)
                flag=0;
            }
        });
        sendup.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if(methodState == 0)
                flag=1;

            }
        });
        senddown.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if(methodState == 0)
                flag=2;

            }
        });
        sendleft.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if(methodState == 0)
                flag=4;

            }
        });
        sendright.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if(methodState == 0)
                flag=8;
            }
        });
        pressMode.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                methodState = 0;
            }
        });
        gestureMode.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                methodState = 1;
            }
        });

      new Thread() {
            public void run() {
                Bundle bundle = new Bundle();
                bundle.clear();
                OutputStream output;
                String str = "hello";

                byte[] inputByte = null;
                int length = 0;


                try {
                    serverSocket = new ServerSocket(30000);
                    while (true) {
                        Message msg = new Message();
                        msg.what = 0x11;

                        try {
                            socket = serverSocket.accept();
                            outStream = socket.getOutputStream();
                            InputStream dis =new DataInputStream(socket.getInputStream());
                            if(flag==0)
                            {
                                try {
                                    outStream.write("0\n".getBytes("gbk"));
                                } catch (IOException e) {

                                    e.printStackTrace();}

                            }
                            else if(flag==1)
                            {
                                try {
                                   outStream.write("1\n".getBytes("gbk"));
                                } catch (IOException e) {

                                    e.printStackTrace();}
                            }
                            else if(flag==2)
                            {
                                try {
                                    outStream.write("2\n".getBytes("gbk"));
                                } catch (IOException e) {

                                    e.printStackTrace();}
                            }
                            else if(flag==4)
                            {
                                try {
                                    outStream.write("4\n".getBytes("gbk"));
                                } catch (IOException e) {

                                    e.printStackTrace();}
                            }
                            else if(flag==8)
                            {
                                try {
                                   outStream.write("8\n".getBytes("gbk"));
                                } catch (IOException e) {

                                    e.printStackTrace();}
                            }
                            else
                            {
                                try {
                                   outStream.write("9\n".getBytes("gbk"));
                                } catch (IOException e) {

                                    e.printStackTrace();}
                            }
                            flag=-1;
                            outStream.flush();
                            socket.shutdownOutput();

                            ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
                            inputByte=new byte[1024];
                            while ((length = dis.read(inputByte,0,inputByte.length))>0) {
                                bytestream.write(inputByte, 0, length);
                            }
                           byte[] imageData=bytestream.toByteArray();
                            bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.length);
                            mHandler.sendMessage(msg);
                            Log.i("tag", "" + imageData.length);
                            //im.setImageBitmap(bitmap);
                            bytestream.flush();
                            bytestream.close();
                            outStream.close();
                            dis.close();


                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                } catch (IOException e1) {
                    // TODO Auto-generated catch block
                    e1.printStackTrace();
                }
            };
        }.start();
    }

    private String getlocalip(){
        WifiManager wifiManager = (WifiManager)getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        int ipAddress = wifiInfo.getIpAddress();
        //  Log.d(Tag, "int ip "+ipAddress);
        if(ipAddress==0)return null;
        return ((ipAddress & 0xff)+"."+(ipAddress>>8 & 0xff)+"."
                +(ipAddress>>16 & 0xff)+"."+(ipAddress>>24 & 0xff));
    }

//gesture
public boolean onTouchEvent(MotionEvent event) {
   return this.myGesture.onTouchEvent(event);
    // return super.onTouchEvent(event);
}

    @Override
    public boolean onDoubleTap(MotionEvent e) {
        flag=0;
        return true;
    }

    @Override
    public boolean onSingleTapConfirmed(MotionEvent e) {
        return true;
    }

    @Override
    public boolean onDoubleTapEvent(MotionEvent e) {
        return true;
    }

    @Override
    public boolean onDown(MotionEvent e) {
        return true;
    }

    @Override
    public void onShowPress(MotionEvent e) {
    }

    @Override
    public boolean onSingleTapUp(MotionEvent e) {
        return true;
    }

    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {

        return true;
    }

    @Override
    public void onLongPress(MotionEvent e) {

    }

    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
        if(methodState==1) {
            if (e1.getX() - e2.getX() > 256 && (e1.getY() - e2.getY() < e1.getX() - e2.getX() || e2.getY() - e1.getY() < e1.getX() - e2.getX()))
                flag = 4;//left
            else if (e2.getX() - e1.getX() > 256 && (e1.getY() - e2.getY() < e2.getX() - e1.getX() || e2.getY() - e1.getY() < e2.getX() - e1.getX()))
                flag = 8;//right
            else if (e1.getY() - e2.getY() > 256 && (e1.getX() - e2.getX() < e1.getY() - e2.getY() || e2.getX() - e1.getX() < e1.getY() - e2.getY()))
                flag = 1;//up
            else if (e2.getY() - e1.getY() > 256 && (e1.getX() - e2.getX() < e2.getY() - e1.getY() || e2.getX() - e1.getX() < e2.getY() - e1.getY()))
                flag = 2;//down
        }
        return true;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


}
