package com.the356company.arexplorer

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Read from shared preferences saved by Flutter home_widget
                val streakStr = widgetData.getString("streak_count", "0")
                val xpStr = widgetData.getString("total_xp", "0")

                setTextViewText(R.id.widget_streak, "$streakStr Days")
                setTextViewText(R.id.widget_xp, xpStr)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
