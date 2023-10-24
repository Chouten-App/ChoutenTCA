let reqId = 0;
let resolveFunctions = {};

const Native = {};
Native.sendHttpRequest = window.webkit.messageHandlers.Native.postMessage;

window.onmessage = async function (event) {
    const data = JSON.parse(event.data);
    let payload = {};

    try{
        payload = JSON.parse(data.payload);
    }catch(err){
        payload = data.payload;
    }

    if (data.action === "logic"){
        try{
            if(payload.action === "eplist"){
                await getEpList(payload);
            }else if(payload.action === "video"){
                await getSource(payload);
            }else{
                console.log("Running Logic!")
                await logic(payload);
            }
        }catch(err){
            console.error(err);
            sendSignal(1, err.toString());
        }
    }else{
        try {
            resolveFunctions[data.reqId](data.responseText);
        } catch (error) {
            
            //console.log(error)
        }
    }
}

function sendRequest(url, headers, method, body) {
    return new Promise((resolve, reject) => {
        const currentReqId = (++reqId).toString();

        resolveFunctions[currentReqId] = resolve;

        // @ts-ignore
        window.webkit.messageHandlers.Native.postMessage(JSON.stringify({
            reqId: currentReqId,
            action: "HTTPRequest",
            url,
            headers,
            method: method,
            body: body
        }));
    });
}

function sendResult(result, last = false) {
    const currentReqId = (++reqId).toString();

    // @ts-ignore
    window.webkit.messageHandlers.Native.postMessage(JSON.stringify({
        reqId: currentReqId,
        action: "result",
        shouldExit: last,
        result: JSON.stringify({action: result.action, result: JSON.stringify(result.result)})
    }));
}

function sendSignal(signal, message = ""){
    const currentReqId = (++reqId).toString();

    // @ts-ignore
                        window.webkit.messageHandlers.Native.postMessage(JSON.stringify({
        reqId: currentReqId,
        action: signal === 0 ? "exit" : "error",
        result: message
    }));
}

function loadScript(url){
    return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        
        script.src = url;
        script.onload = resolve;
        script.onerror = reject;

        document.head.appendChild(script);
    });
}
