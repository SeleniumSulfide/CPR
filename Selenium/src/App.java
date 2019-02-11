

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.WebDriverWait;

import util.Data.MSSQL;

import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.FluentWait;

public class App 
{
	int defaultTimeout = 30;
	int defaultPolling = 1;
	
	WebDriver driver;
	FluentWait<WebDriver> fwait;
	
	public App(WebDriver driver)
	{
		this.driver = driver;
		SetTimings(defaultTimeout, defaultPolling);
	}
	
	public void SetTimings(int Timeout, int Polling)
	{
		fwait = new FluentWait<WebDriver>(driver)
				.withTimeout(Timeout, TimeUnit.SECONDS)
				.pollingEvery(Polling, TimeUnit.SECONDS)
				.ignoring(NoSuchElementException.class)
				.ignoring(TimeoutException.class)
				.ignoring(StaleElementReferenceException.class);
	}
	
	public Boolean fluentWaitForElementLocated(By by)
	{
		Boolean success = false;
		
		try
		{
			fwait.until(ExpectedConditions.visibilityOfElementLocated(by));
			success = true;
		}
		catch (Exception e)
		{
	        e.printStackTrace();
	        success = false;
		}
		
		return success;
	}
	
	public Boolean fluentWaitForElement(WebElement element)
	{
		Boolean success = false;
		List<WebElement> elements = new ArrayList<WebElement>();
		elements.add(element);
		
		try
		{
			fwait.until(ExpectedConditions.visibilityOfAllElements(elements));
			success = true;
		}
		catch (Exception e)
		{
	        e.printStackTrace();
	        success = false;
		}
		
		return success;
	}
	
	public void waitForReadyStateComplete()
	{
		new WebDriverWait(driver, defaultTimeout).until(webDriver -> ((JavascriptExecutor) webDriver).executeScript("return document.readyState").equals("complete"));
	}

	public void HoverClick(WebElement hover, WebElement click)
	{	
		new Actions(driver).moveToElement(hover).perform();
		click.click();
	}
	
	public void HoverClick(WebElement hover, int xOffset, int yOffset, WebElement click)
	{	
		//new Actions(driver).moveToElement(hover).moveByOffset(xOffset, yOffset).perform();
		new Actions(driver).moveToElement(hover, xOffset, yOffset).perform();
		click.click();
	}
	
	public void Sleep()
	{
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
	public void Sleep(int Millis)
	{
		try {
			Thread.sleep(Millis);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
	public Integer getInt(ResultSet rs, String Column)
	{
		Integer integer = 0;
		try 
		{
			if (rs.next())
			{
				integer = rs.getInt(Column);
			}
		} 
		catch (SQLException e) 
		{
			e.printStackTrace();
		}
		
		return integer;
	}
	
	public ResultSet getRS(MSSQL sql, String SQL)
	{
		return sql.ExecuteSQL(SQL);
	}
	
	public Date parseDate(String date, String format)
	{
		SimpleDateFormat dateFormat = new SimpleDateFormat(format);
		try {
			return dateFormat.parse(date);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}
	
	public Date parseDate(String date)
	{
		return parseDate(date, "MM/dd/yyyy");		
	}
}
