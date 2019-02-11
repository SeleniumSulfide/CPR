package util.BaseControls;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class TextBox extends Button 
{	
	public TextBox(WebDriver driver, By by)
	{
		super(driver, by);
	}
	
	public TextBox(WebElement element, WebDriver driver, By by)
	{
		super(element, driver, by);
	}
	
	public void SendKeys(String keys)
	{
		GetElement().sendKeys(keys);
	}
	
	public void Clear()
	{
		GetElement().clear();
	}
}
