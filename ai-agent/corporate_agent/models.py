from pydantic import BaseModel, Field
from typing import Optional, Literal, Any


class FinalPresentation(BaseModel):
    """
    Model representing the final presentation format for query results.
    """
    response_type: Literal["visual", "text", "unable_to_answer"] = Field(
        ..., description="Type of response to present: 'visual' if a chart is included, 'text' for simple text information, or 'unable_to_answer' if the query cannot be answered."
    )

    summary_text: str = Field(
        ..., description="A brief summary text that explains the results or the reason for being unable to answer."
    )

    vega_lite_spec: Optional[str] = Field(
        None, description="A Vega-Lite v5 JSON specification as a JSON string for visual representation of the data. Must be a complete JSON string with data and encoding fields for visual responses. Set to null for text and unable_to_answer responses."
    )
