package util.BaseControls;

import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

public class DropDown extends Label
{
	Select select;
	
	public DropDown(WebDriver driver, By by)
	{
		super(driver, by);
	}
	
	public DropDown(WebElement element, WebDriver driver, By by)
	{
		super(element, driver, by);
	}
	
	public void SetByValue(String value)
	{
		GetSelect().selectByValue(value);
	}
	
	public void SetByVisibleText(String text)
	{
		GetSelect().selectByVisibleText(text);
	}
	
	public void SetByIndex(int index)
	{
		GetSelect().selectByIndex(index);
	}
	
	public String GetSelected()
	{
		return GetSelect().getFirstSelectedOption().getText();
	}
	
	public List<String> GetOptions()
	{
		List<String> options = new ArrayList<String>();
		
		for (WebElement option : GetSelect().getOptions())
		{
			options.add(option.getText());
		}
		
		return options;
	}
	
	public Select GetSelect()
	{
		return new Select(GetElement());
	}
}
