package util.BaseControls;

import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class ErrorMessages extends Label
{	
	public List<String> GetErrors()
	{
		List<WebElement> elements = this.driver.findElements(by);
		List<String> errors = new ArrayList<String>();
		
		for (WebElement element : elements)
		{
			errors.add(element.getText());
		}
		return errors;
	}
	
	public ErrorMessages(WebDriver driver, By by)
	{
		super(driver, by);
	}
}