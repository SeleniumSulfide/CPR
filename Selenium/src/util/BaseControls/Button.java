package util.BaseControls;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class Button extends Label
{	
	public Button(WebDriver driver, By by)
	{
		super(driver, by);
	}
	
	public Button(WebElement element, WebDriver driver, By by)
	{
		super(element, driver, by);
	}
	
	public void Click()
	{
		GetElement().click();
	}
}
