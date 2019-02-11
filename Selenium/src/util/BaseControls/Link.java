package util.BaseControls;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;

public class Link extends Button
{
	
	public Link(WebDriver driver, By by)
	{
		super(driver, by);
	}
	
	public Link(WebElement element, WebDriver driver, By by)
	{
		super(element, driver, by);
	}
	
	public void HoverOver()
	{
		Actions action = new Actions(driver);
		action.moveToElement(GetElement()).build().perform();
	}
	
	public String GetHREF()
	{
		return GetAttribute("href");
	}
}
