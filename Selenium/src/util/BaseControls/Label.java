package util.BaseControls;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import CapStock.App;

public class Label 
{
	
	WebDriver driver;
	By by;
	WebElement element;
	App app;
	
	public Label(WebDriver driver, By by)
	{
		this.driver = driver;
		this.by = by;
		app = new App(this.driver);
	}
	
	public Label(WebElement element, WebDriver driver, By by)
	{
		this.element = element;
		this.by = by;
		this.driver = driver;
		app = new App(this.driver);
	}
	
	public String GetAttribute(String attribute)
	{
		return GetElement().getAttribute(attribute);
	}
	
	public String GetValue()
	{
		return GetAttribute("value");
	}
	
	public double GetValueAsDouble()
	{
		
		return Double.parseDouble(GetValue().replace("$", "").replaceAll(",", ""));
	}
	
	public Date GetValueAsDate()
	{
		try { return new SimpleDateFormat("MM/dd/yyyy").parse(GetValue()); }
		catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}
	
	public String GetText()
	{
		return GetElement().getText();
	}
	
	public WebElement GetElement()
	{
		if (driver != null)
		{
			return driver.findElement(by);
		}
		else
		{
			return element.findElement(by);
		}
	}
	
	public Boolean isDisplayed()
	{
		if (driver != null)
		{
			return driver.findElement(by).isDisplayed();
		}
		else
		{
			return element.findElement(by).isDisplayed();
		}
	}
	
	public Boolean waitTillExists()
	{
		if (driver != null)
		{
		return  app.fluentWaitForElementLocated(by);
		}
		else
		{
			return app.fluentWaitForElement(element);
		}
	}
}
