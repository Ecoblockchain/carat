package edu.berkeley.cs.amplab.carat.android.ui;

import org.apache.thrift.TException;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.view.Window;
import android.widget.TextView;
import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.thrift.Reports;

/**
 * Communicates with the Carat Server. Sends samples stored in CaratDB every
 * COMMS_INTERVAL ms.
 * 
 * @author Eemil Lagerspetz
 * 
 */
public class UiRefreshThread extends Thread {

    private static final String TAG = "UiRefreshThread";

    private boolean isRunning = true;

    private static final String TRY_AGAIN = " will try again in "
            + (CaratApplication.FRESHNESS_TIMEOUT / 1000) + "s.";

    CaratApplication app = null;
    
    private static UiRefreshThread instance = null;
    
    public static UiRefreshThread getInstance(){
        return instance;
    }

    public UiRefreshThread(CaratApplication app) {
        this.app = app;
        instance = this;
    }

    public void stopRunning() {
        isRunning = false;
    }

    public void appResumed() {
        synchronized (UiRefreshThread.this) {
            UiRefreshThread.this.interrupt();
        }
    }

    public void run() {
        boolean connecting = false;
        Context c = app.getApplicationContext();
        Log.i(TAG, "Refresh thread started.");

        while (isRunning) {
            String networkStatus = SamplingLibrary.getNetworkStatus(c);
            if (networkStatus == SamplingLibrary.NETWORKSTATUS_CONNECTED) {
                try {
                    app.c.refreshAllReports();
                    Log.i(TAG, "Reports refreshed.");
                } catch (TException e1) {
                    Log.w(TAG, "," + TRY_AGAIN);
                    e1.printStackTrace();
                }
            } else if (networkStatus
                    .equals(SamplingLibrary.NETWORKSTATUS_CONNECTING)) {
                Log.w(TAG, "Network status: " + networkStatus
                        + ", trying again in 10s.");
                connecting = true;
            } else {
                Log.w(TAG, "Network status: " + networkStatus + TRY_AGAIN);
            }
            // do this regardless
            setReportData();
            
            if (connecting) {
                // wait for wifi to come up
                try {
                    sleep(CaratApplication.COMMS_WIFI_WAIT);
                } catch (InterruptedException e1) {
                    // ignore
                }
                connecting = false;
            } else {
                try {
                    sleep(CaratApplication.COMMS_INTERVAL);
                } catch (InterruptedException e) {
                    // wait for wifi to come up
                    try {
                        sleep(CaratApplication.COMMS_WIFI_WAIT);
                    } catch (InterruptedException e1) {
                        // ignore
                    }
                }
            }
        }
        Log.i(TAG, "Refresh thread stopped.");
    }
    
    private void setReportData() {
        final Reports r = app.s.getReports();
        Log.i("CaratHomeScreen", "Got reports: " + r);
        long l = System.currentTimeMillis() - app.s.getFreshness();
        final long min = l / 60000;
        final long sec = (l - min * 60000) / 1000;
        double bl = 0;
        int jscore = 0;
        if (r != null) {
            bl = 100 / r.getModel().expectedValue;
            jscore = ((int) (r.getJScore() * 100));
        }
        int blh = (int) (bl / 3600);
        bl -= blh * 3600;
        int blmin = (int) (bl / 60);
        int bls = (int) (bl - blmin * 60);
        final String blS = blh + "h " + blmin + "m " + bls + "s";
        CaratApplication.setText(R.id.jscore_value, jscore + "");
        CaratApplication.setText(R.id.updated, "(Updated " + min + "m " + sec + "s ago)");
        CaratApplication.setText(R.id.batterylife_value, blS);
    }
}