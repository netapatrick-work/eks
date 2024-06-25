# Install AddOns
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done

# # Uninstall AddOns
# for ADDON in kiali jaeger prometheus grafana
# do
#     ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
#     kubectl delete -f $ADDON_URL
# done


