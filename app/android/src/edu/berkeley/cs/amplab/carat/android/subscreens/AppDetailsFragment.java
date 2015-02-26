package edu.berkeley.cs.amplab.carat.android.subscreens;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.ui.DrawView;
import edu.berkeley.cs.amplab.carat.android.utils.Tracker;
import edu.berkeley.cs.amplab.carat.thrift.DetailScreenReport;
import edu.berkeley.cs.amplab.carat.thrift.Reports;

public class AppDetailsFragment extends Fragment {

	@Override
	public void onResume() {
		super.onResume();
		if (fullObject != null)
			getActivity().setTitle(fullObject.getAppName());
	}

	private SimpleHogBug fullObject;
	private boolean isApp = false;
	private boolean isOs = false;
	private double ev, error, evWithout, errorWo;
	private int samplesCount, samplesCountWithout;
	private static AppDetailsFragment instance = null;
	private final MainActivity mMainActivity = CaratApplication.getMainActivity();

	/*
	 * @Param type the type of the details we would like to display. Supported
	 * values are: TYPE.OS, TYPE.MODEL, TYPE.OTHER. To specify that we'd like to
	 * show the details of a erroneous app (bug or hog), pass the type BUG as
	 * the first argument. Pass TYPE.OS for OS details and TYPE.MODEL for device
	 * details.
	 */
	public static AppDetailsFragment getInstance(Constants.Type type, SimpleHogBug fullObject, boolean isBugs) {
		if (instance == null)
			instance = new AppDetailsFragment();
		setInstanceFields(type, fullObject, isBugs);
		return instance;
	}

	private static void setInstanceFields(Constants.Type type, SimpleHogBug fullObject, boolean isBugs) {
		switch (type) {
		case BUG:
			instance.isApp = true;
			instance.isOs = false;
			instance.setFullObject(fullObject);
			break;
		case OS:
			instance.isApp = false;
			instance.isOs = true;
			break;
		case MODEL:
			instance.isApp = false;
			instance.isOs = false;
			break;
		default:
			throw new IllegalArgumentException("only the types BUG, OS, or MODEL can be passed");
		}
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View detailsPage = inflater.inflate(R.layout.graph, container, false);
		DrawView drawView = new DrawView(getActivity());

		if (isApp) {
			drawView.setParams(fullObject, detailsPage);
			setBenefitTextView(detailsPage, fullObject.getBenefitText());
		} else { // isOS or isModel
			Reports reports = CaratApplication.getStorage().getReports();
			if (reports != null) {
				Tracker tracker = Tracker.getInstance(getActivity());
				if (isOs) {
					setOsWidgets(detailsPage, drawView, reports, tracker);
				} else { // isModel
					setModelWidgets(detailsPage, drawView, reports, tracker);
				}
				// common piece of code for both OS and Model
				setBenefitWidget(detailsPage);
			}
			Log.d("NullReports", "Reports are null!!!");
		}
		// common piece of code for App, OS, and Model
		setDescriptionWidgets(detailsPage);

		// onCreateView() should return the view resulting from inflating the
		// layout file
		return detailsPage;
	}

	private void setOsWidgets(View detailsPage, DrawView drawView, Reports reports, Tracker tracker) {
		DetailScreenReport os = reports.getOs();
		DetailScreenReport osWithout = reports.getOsWithout();
		String label = getString(R.string.os) + ": " + SamplingLibrary.getOsVersion();
		setDetails(os, osWithout);
		drawView.setParams(Constants.Type.OS, label, ev, evWithout, samplesCount, samplesCountWithout, error, errorWo,
				detailsPage);

		Log.v("OsInfo", "Os score: " + os.getScore());
		tracker.trackUser("osInfo", getActivity().getTitle());
	}

	private void setModelWidgets(View detailsPage, DrawView drawView, Reports reports, Tracker tracker) {
		DetailScreenReport model = reports.getModel();
		DetailScreenReport modelWithout = reports.getModelWithout();
		String label = getString(R.string.model) + ": " + SamplingLibrary.getModel();
		setDetails(model, modelWithout);
		drawView.setParams(Constants.Type.MODEL, label, ev, evWithout, samplesCount, samplesCountWithout, error, errorWo,
				detailsPage);

		Log.v("ModelInfo", "Model score: " + model.getScore());
		tracker.trackUser("deviceInfo",  getActivity().getTitle());
	}

	private void setBenefitWidget(View detailsPage) {
		String benefitText = SimpleHogBug.getBenefitText(ev, error, evWithout, errorWo);
		if (benefitText == null)
			benefitText = getString(R.string.jsna);
		((TextView) detailsPage.findViewById(R.id.benefit)).setText(benefitText);
	}
	
	private void setBenefitTextView(View detailsPage, String benefit) {
		TextView tv1 = (TextView) detailsPage.findViewById(R.id.benefit);
		tv1.setText(benefit);
	}

	/*
	 * when user taps on either the more info arrow or the expected improvement
	 * value (at top), the description screen shows up
	 */
	private void setDescriptionWidgets(View detailsPage) {
		View moreinfo = detailsPage.findViewById(R.id.jscore_info);
		View benefit = detailsPage.findViewById(R.id.benefit);
		moreinfo.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View view) {
				mMainActivity.showHTMLFile("detailinfo", getString(R.string.moreinfo), false);
			}
		});
		benefit.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View view) {
				mMainActivity.showHTMLFile("detailinfo", getString(R.string.moreinfo), false);
			}
		});
	}
	
	private void setDetails(DetailScreenReport obj, DetailScreenReport objWithout) {
		this.ev = obj.getExpectedValue();
		this.error = obj.getError();
		this.evWithout = objWithout.getExpectedValue();
		this.errorWo = objWithout.getError();
		this.samplesCount = (int) obj.getSamples();
		this.samplesCountWithout = (int) objWithout.getSamples();
	}

	public void setFullObject(SimpleHogBug fullObject) {
		this.fullObject = fullObject;
	}
}
